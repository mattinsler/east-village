stable_sort = (items, get_value, comparator) ->
  items.map (item, idx) ->
    {idx: idx, item: item, data: get_value(item)}
  .sort (lhs, rhs) ->
    v = comparator(lhs.data, rhs.data)
    return v unless v is 0
    if lhs.idx < rhs.idx then -1 else 1
  .map (o) ->
    o.item

((exports) ->
  class CollectionView extends Backbone.View
    
    initialize: ->
      super
      
      _(@).extend(_.pick(@options, 'item_view', 'comparator', 'sort_by', 'filter', 'reverse'))
            
      @_sort_by = @sort_by
      Object.defineProperty @, 'sort_by', {
        get: -> @_sort_by
        set: (val) ->
          @_sort_by = val
          @render()
      }
      
      @_filter = @filter
      Object.defineProperty @, 'filter', {
        get: -> @_filter
        set: (val) ->
          @_filter = val
          @render()
      }
      
      @collection.on('reset', @on_reset, @)
      @collection.on('add', @on_add, @)
      @collection.on('remove', @on_remove, @)
      
      @visible_count = 0
      Object.defineProperty @, 'visible_items', {get: => @items.filter (i) -> i.visible}
    
    _sort_items: ->
      do_sort = =>
        if @_sort_by?
          keys = _(@_sort_by).keys()
          directions = _(@_sort_by).values().map (d) ->
            if d.toLowerCase() in ['desc', 'descending']
              (v) -> -1 * v
            else
              (v) -> v
          
          get_value = (model) ->
            keys.map (k) ->
              v = model.item.get(k)
              return v.toLowerCase() if typeof v is 'string'
              v
          comparison = (lhs, rhs) ->
            for idx in [0...directions.length]
              continue if lhs[idx] is rhs[idx]
              return directions[idx](reversed * (if lhs[idx] > rhs[idx] or !lhs[idx]? then 1 else -1))
            0
              
        else if @comparator?
          get_value = (o) =>
            v = @comparator(o.item)
            return v.toLowerCase() if typeof v is 'string'
            v
          comparison = (lhs, rhs) ->
            return 0 if lhs is rhs
            reversed * (if lhs > rhs or !lhs? then 1 else -1)
        
        if get_value? and comparison?
          reversed = if @reverse then -1 else 1
          @items = stable_sort(@items, get_value, comparison)

        @items[idx].index = idx for idx in [0...@items.length]
      
      on_model_change = ->
        @render()
      
      bind = =>
        @collection.on("change:#{k}", on_model_change, @) for k in Object.keys(@_sort_by)
      unbind = =>
        @collection.off("change:#{k}", on_model_change, @) for k in Object.keys(@_sorted_by)
      
      if @_sorted_by?
        unbind() unless @_sort_by? and _.isEqual(@_sorted_by, @_sort_by)
      if @_sort_by?
        @_sorted_by = _.clone(@_sort_by)
        bind()
      
      do_sort()
    
    on_reset: ->
      @trigger('before:reset', @)
      @rendered = false
      @render()
      @trigger('after:reset', @)
    
    on_add: (item, collection, options) ->
      return if @cid_to_item[item.cid]?
      
      view = new @item_view(model: item)
      item_data = {
        item: item
        view: view
      }
      
      @trigger('before:add', item_data, @)
      
      @items.push(item_data)
      @cid_to_item[item.cid] = item_data
      
      @_sort_items()
      @items[idx].index = idx for idx in [0...@items.length]
      
      if !@_filter? or @_filter(item_data.item)
        @add_item_to_view(item_data, render: true, transition: 'slideDown')
      
      @trigger('after:add', item_data, @)
    
    on_remove: (item, collection, options) ->
      return unless @cid_to_item[item.cid]?
      
      @trigger('before:remove', item_data, @)
      
      item_data = @cid_to_item[item.cid]
      delete @cid_to_item[item.cid]
      
      item_data.view.off()
      @remove_item_from_view(item_data, remove: true, transition: 'slideUp')
      
      @items.splice(item_data.index, 1)
      @items[idx].index = idx for idx in [0...@items.length]
      
      @trigger('after:remove', item_data, @)
    
    add_item_to_view: (item, opts = {}) ->
      @trigger('before:show:item', item, @)
      
      TRANSITIONS = {
        default: (item, insert) ->
          insert(item)
          item.view.$el.show()
        slideDown: (item, insert) ->
          item.view.$el.hide()
          insert(item)
          item.view.$el.slideDown()
      }
      
      unless item.visible
        @visible_count += 1
        item.view.render() if opts.render
      
      transition = TRANSITIONS[opts?.transition] ? TRANSITIONS.default
      if opts.append
        insert = (item) =>
          @$el.append(item.view.el)
      else
        insert = (item) =>
          if @items.length is 1 or @visible_count is 1 or item.index is @items.length - 1
            @$el.append(item.view.el)
          else
            next = @items[item.index + 1].view.el
            $(next).before(item.view.el)
      
      transition(item, insert)
      
      item.visible = true
      
      @trigger('after:show:item', item, @)
    
    remove_item_from_view: (item, opts = {}) ->
      @trigger('before:hide:item', item, @)
      
      TRANSITIONS = {
        default: (item, cb) ->
          item.view.$el.hide()
          cb()
        slideUp: (item, cb) ->
          item.view.$el.slideUp(cb)
      }
      
      transition = TRANSITIONS[opts?.transition] ? TRANSITIONS.default
      transition_complete = ->
        item.view.remove() if opts.remove
      
      if item.visible
        @visible_count -= 1
        transition(item, transition_complete)
      else
        transition_complete()
      
      item.visible = false
      
      @trigger('after:hide:item', item, @)

    re_render: ->
      return @render() unless @rendered
      
      @trigger('before:render', @)
      
      @_sort_items()
      
      @visible_count = 0
      @items.forEach (item) =>
        if !@_filter? or @_filter(item.item)
          @add_item_to_view(item, append: true)
        else
          @remove_item_from_view(item, transition: 'slideUp')
      
      @trigger('after:render', @)
    
    render: ->
      return @re_render() if @rendered
      
      @rendered = true
      @trigger('before:render', @)
      
      @$el.empty()
      
      @cid_to_item = {}
      @items = Array::slice.call(@collection.models)
      @items = @items.map (item, idx) =>
        item_data = {
          item: item
          view: new @item_view(model: item)
        }
        @cid_to_item[item.cid] = item_data
        item_data
      @_sort_items()
      
      @visible_count = 0
      @items.forEach (item) =>
        @add_item_to_view(item, render: true, append: true) if !@_filter? or @_filter(item.item)
      
      @trigger('after:render', @)
  
  exports.CollectionView = CollectionView
)(window)
