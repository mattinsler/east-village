import 'ApiController'

Github = require 'github.node'

class ApiReposController extends ApiController
  before_action (next) ->
    return next(new Error()) unless @current_user.accounts.github?.access_token?
    @github_client = new Github(access_token: @current_user.accounts.github.access_token)
    next()
  
  index: ->
    @github_client.repos.list (err, repos) =>
      return @error(err) if err?
      @render(json: repos)
  
  show: ->
    @github_client.repo(@params.id).get (err, data) =>
      return @error(err) if err?
      @render(json: data)
