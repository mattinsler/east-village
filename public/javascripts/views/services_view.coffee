class App.ServiceItemView extends Backbone.View
  template: @template('service_item')
  tagName: 'li'
  initialize: -> Spellbinder.initialize(@)
  
  render: ->
    $root = @$el
    
    @$('a.show-hide').each ->
      id = $(@).attr('href')
      text = ($(@).data('text') || '').trim()
      text = ' ' + text if text.length > 0
      $el = $root.find(id)
      $(@).html('Show' + text + '...')
      $el.addClass('hide')
      
      $(@).on 'click', (e) ->
        $el.toggleClass('hide')
        $(@).html((if $el.is(':visible') then 'Hide' else 'Show') + text + '...')
        e.preventDefault()
        false

class App.ServicesView extends Backbone.View
  template: @template('services')
  
  initialize: ->
    Spellbinder.initialize(@)
    @collection = new App.Services()
    @collection.fetch()
  
  render: ->
    service_list = new CollectionView(
      el: @$('ul.services')
      collection: @collection
      item_view: App.ServiceItemView
      sort_by: {
        name: 'asc'
      }
    ).render()
