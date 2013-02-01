import 'ApplicationController'

class AuthenticatedController extends ApplicationController
  before_action (next) ->
    return @redirect_to('/') unless @current_user?
    next()
