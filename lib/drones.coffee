_ = require 'underscore'
async = require 'async'
forever = require 'forever'
# start_daemon = Caboose.path.lib.join('start_daemon').require()

EAST_VILLAGE_UID = 'east-village'

services = {
  list: (callback) ->
    forever.list false, (err, procs) ->
      return callback(err) if err?

      procs ?= []
      callback(null,
        procs
          .map (p, idx) ->
            p.id = idx
            p.full_command = [p.command, p.file].concat(p.options).join(' ')
            p.name = p.spawnWith.east_village_name
            p
          .filter((p) -> p.uid isnt EAST_VILLAGE_UID)
      )
  
  # start_service: (config, callback) ->
  #   if typeof config is 'string'
  #     svc_config = services.config[config]
  #     return process.nextTick(-> callback(new Error("No service named '#{config}'"))) unless svc_config?
  #     return services.start_service(svc_config, callback)
  #   
  #   log_dir = Caboose.root.join('logs')
  #   pid_dir = Caboose.root.join('pids')
  # 
  #   log_dir.mkdir_sync() unless log_dir.exists_sync()
  #   pid_dir.mkdir_sync() unless pid_dir.exists_sync()
  # 
  #   opts = _.clone(service.options)
  #   opts.uid = EAST_VILLAGE_UID
  #   opts.logFile = log_dir.join(service.full_command.split(' ')[0] + '.log').path
  #   opts.pidFile = pid_dir.join(service.full_command.split(' ')[0] + '.pid').path
  # 
  #   start_daemon(service.full_command, opts)
  #   process.nextTick(callback)
  # 
  # ensure_all_running: (callback) ->
  #   services.list (err, procs) ->
  #     return callback(err) if err?
  #     
  #     procs = _(procs).groupBy (s) -> s.full_command
  #     
  #     work = _(services.config).values().filter (s) ->
  #       return true unless procs[s.full_command]?
  #       return true if procs[s.full_command].length < 1
  #       false
  #     .map (s) ->
  #       (cb) -> services.start_service(config, cb)
  #     
  #     async.parallel(work, callback)
}

module.exports = services
