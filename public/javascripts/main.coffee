class Application
  root: ''
  current_user: window.__bootstrap__?.current_user
  
  start: ->
    new @ApplicationRouter()
    
    @start_backbone(@root)
    
  start_backbone: (root) ->
    Backbone.history.start(root: root)
    
    $('a:not([data-bypass])').on 'click', (evt) ->
      href = $(@).prop('href')
      root_href = "#{window.location.protocol}//#{window.location.host}#{root}"

      if href? and href.slice(0, root.length) is root_href
        Backbone.history.navigate(href.slice(root_href.length), true)
        evt.preventDefault()
        false
    
    console.log 'STARTED'

Backbone.View.template = (name) ->
  html = $('#templates [data-name="' + name + '"]').html()
  ejs.compile(html)

$.ajaxPrefilter (options, originalOptions, jqXHR) ->
  options.xhrFields = {
    withCredentials: true
  }

window.App = new Application()

$ -> window.App.start()
