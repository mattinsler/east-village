import 'AuthenticatedController'

class ApiController extends AuthenticatedController
  before_action (next) ->
    @params.format = 'json'
    next()
