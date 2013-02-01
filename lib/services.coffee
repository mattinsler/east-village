_ = require 'underscore'
async = require 'async'
forever = require 'forever'
start_daemon = Caboose.path.lib.join('start_daemon').require()

EAST_VILLAGE_UID = 'east-village'

SERVICES = {
  axle: {
    full_command: 'axle'
    options: {
      env: {
        PORT: Caboose.app.config.axle.port || 2020
      }
    }
  }
}

v.name = k for k, v of SERVICES

services = {
  config: SERVICES
  
  list: (callback) ->
    forever.list false, (err, procs) ->
      return callback(err) if err?
      
      summary = _(services.config).inject (o, v, k) ->
        o[k] = 0
        o
      , {}
      
      running = (procs ? [])
        .filter((p) -> p.uid is EAST_VILLAGE_UID)
        .map (p, idx) ->
          p.id = idx
          p.full_command = [p.command, p.file].concat(p.options).join(' ')
          p.name = p.spawnWith.east_village_name
          p.running = true
          ++summary[p.name]
          p
      
      not_running = _(services.config)
        .map (v, k) ->
          v.name = k
          v.running = false
          v
        .filter (s) -> summary[s] is 0
      
      callback(null, {
        summary: summary
        running: running
        not_running: not_running
      })
  
  start_service: (config, callback) ->
    if typeof config is 'string'
      svc_config = services.config[config]
      return process.nextTick(-> callback(new Error("No service named '#{config}'"))) unless svc_config?
      return services.start_service(svc_config, callback)
    
    log_dir = Caboose.root.join('logs')
    pid_dir = Caboose.root.join('pids')

    log_dir.mkdir_sync() unless log_dir.exists_sync()
    pid_dir.mkdir_sync() unless pid_dir.exists_sync()

    opts = _.clone(config.options)
    opts.uid = EAST_VILLAGE_UID
    opts.spawnWith = {east_village_name: config.name}
    opts.logFile = log_dir.join(config.name + '.log').path
    opts.pidFile = pid_dir.join(config.name + '.pid').path
    
    start_daemon(config.full_command, opts)
    process.nextTick(callback)
  
  ensure_all_running: (callback) ->
    services.list (err, procs) ->
      return callback(err) if err?
      
      procs = _(procs).groupBy (s) -> s.full_command
      
      work = _(services.config).values().filter (s) ->
        return true unless procs[s.name]?
        return true if procs[s.name].length < 1
        false
      .map (s) ->
        (cb) -> services.start_service(s, cb)
      
      async.parallel(work, callback)
}

module.exports = services
