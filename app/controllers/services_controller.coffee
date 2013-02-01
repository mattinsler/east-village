import 'ApplicationController'
import 'TerminalColorsHelper'

_ = require 'underscore'
async = require 'async'
forever = require 'forever'
Services = Caboose.path.lib.join('services').require()

class ServicesController extends ApplicationController
  helper TerminalColorsHelper
  
  # index: ->
  #   Services.list (err, procs) =>
  #     async.map procs, (p, cb) ->
  #       forever.tail p.id, 50, (err, logs) ->
  #         return cb(err) if err?
  #         p.logs = logs[0].logs.join('\n')
  #         cb(null, p)
  #     , (err, services) =>
  #       return @error(err) if err?
  #       running_service_names = _(services).pluck('name')
  #       not_running_service_names = _(Services.config).keys().filter (s) -> !_(running_service_names).contains(s)
  #       @services = {
  #         running: services.map (p) -> p.running = true; p
  #         not_running: _.chain(Services.config).pick(not_running_service_names...).values().value().map (p) -> p.running = false; p
  #       }
  #       @render()
  
  logs: ->
    @service_id = @params.services_id
    @render()
