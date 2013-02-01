_ = require 'underscore'
coupler = require 'coupler'
EventEmitter = require('events').EventEmitter

class Version
  constructor: (@containment, vars = {}) ->
    _(@).extend(vars)
    @client = @containment.client
  
  install_dependencies: (cb) -> @client.install_version_dependencies(@user, @project, @version, cb)
  status: (cb) -> @client.version_status(@user, @project, @version, cb)
  start: (cb) -> @client.start_version(@user, @project, @version, cb)
  stop: (cb) -> @client.stop_version(@user, @project, @version, cb)

class Project
  constructor: (@containment, vars = {}) ->
    _(@).extend(vars)
    @client = @containment.client
    
    @versions = {
      list: (cb) => @client.project_versions(@user, @project, cb)
    }
  
  get: (cb) -> @client.get_project(@user, @project, cb)
  update_code: (cb) -> @client.update_project_code(@user, @project, cb)
  version: (version) -> new Version(@containment, user: @user, project: @project, version: version)

class User
  constructor: (@containment, vars = {}) ->
    _(@).extend(vars)
    @client = @containment.client
    
    @projects = {
      list: (cb) => @client.list_projects(@user, cb)
      create: (project, source, source_opts, cb) => @client.create_project(@user, project, source, source_opts, cb)
    }
  
  project: (project) -> new Project(@containment, user: @user, project: project)

class Containment extends EventEmitter
  @cached_client: null
  
  constructor: ->
    Containment.cached_client ?= coupler.connect(tcp: 1234).consume('containment')
    @client = Containment.cached_client
    @client.on 'coupler:connected', =>
      @client.status (err, data) =>
        channel = require('redback').createClient().createChannel(data.log_channel).subscribe()
        channel.on 'message', (data) ->
          Caboose.app.io.sockets.emit('logs', data)
  
  user: (user) -> new User(@, user: user)

module.exports = Containment
