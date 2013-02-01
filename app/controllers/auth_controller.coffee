import 'ApplicationController'

passport = Caboose.app.passport

class AuthController extends ApplicationController
  logout: ->
    @request.logout()
    @redirect_to '/'
  
  before_action (next) ->
    passport.authenticate('github', scope: ['repo'])(@request, @response, next)
  , {only: ['github', 'github_callback']}
  
  github: ->
  github_callback: -> @redirect_to '/'
