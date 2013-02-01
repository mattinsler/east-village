import 'AuthenticatedController'

async = require 'async'
Github = require 'github.node'

class ProjectsController extends AuthenticatedController
  before_action (next) ->
    @containment = Caboose.app.containment.user(@current_user._id.toString())
    @project = @containment.project(@params.id) if @params.id?
    next()
  
  index: ->
    @containment.projects.list (err, projects) =>
      return @error(err) if err?
      @projects = projects
      @render()
  
  show: ->
    async.parallel {
      config: (cb) => @project.get(cb)
      versions: (cb) => @project.versions.list(cb)
    }, (err, data) =>
      return @error(err) if err?
      @data = data
      @render()
  
  new: ->
    client = new Github(access_token: @current_user.accounts.github.access_token)
    client.repos.list (err, repos) =>
      return @error(err) if err?
      @repos = repos
      @render()
  
  create: ->
    @containment.projects.create @body.data.name, 'github', {
      access_token: @current_user.accounts.github.access_token
      repo: @body.data.repo
    }, =>
      console.log arguments
      @redirect_to '/projects'
  
  update_code: ->
    @project.update_code (err, version) =>
      return @error(err) if err?
      @redirect_to '/projects/' + @params.id + '/versions/' + version
