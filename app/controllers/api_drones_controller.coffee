import 'ApiController'

Github = require 'github.node'

class ApiDronesController extends ApiController
  before_action (next) ->
    return next(new Error()) unless @current_user.accounts.github?.access_token?
    @github_client = new Github(access_token: @current_user.accounts.github.access_token)
    next()
  
  clone: ->
    @github_client.repo(@params.id).get (err, data) =>
      return @error(err) if err?
      return @render(json: {error: 'Unknown repo'}) unless data?
      
      
      
      console.log data.git_url
