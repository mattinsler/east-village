class App.ApplicationRouter extends Backbone.Router
  routes:
    '': 'index'
    'services': 'services'
    'drones': 'drones'
  
  index: ->
    return @navigate('services') if App.current_user?
    new App.LoginView(el: '#content').render()
  
  services: ->
    return @navigate('services') unless App.current_user?
    new App.ServicesView(el: '#content').render()
  
  drones: ->
    new App.DronesView(el: '#content').render()
