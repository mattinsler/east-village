import 'AuthenticatedController'

class VersionsController extends AuthenticatedController
  before_action (next) ->
    @params.versions_id = @params.versions_id or @params.id
    @params.versions_id += '.' + @params.format unless @params.format is 'html'
    @params.format = 'html'
    
    @containment = Caboose.app.containment.user(@current_user._id.toString())
    @project = @containment.project(@params.projects_id)
    @version = @project.version(@params.versions_id)
    next()
  
  show: ->
    @version.status (err, status) =>
      return @error(err) if err?
      @status = status
      @render()
  
  install_dependencies: ->
    @version.install_dependencies (err) =>
      console.log(err.stack) if err?
      return @error(err) if err?
      @redirect_to '/projects/' + @params.projects_id + '/versions/' + @params.versions_id
  
  start: ->
    @version.start (err) =>
      console.log(err.stack) if err?
      return @error(err) if err?
      @redirect_to '/projects/' + @params.projects_id + '/versions/' + @params.versions_id
  
  stop: ->
    @version.stop (err) =>
      console.log(err.stack) if err?
      return @error(err) if err?
      @redirect_to '/projects/' + @params.projects_id + '/versions/' + @params.versions_id
