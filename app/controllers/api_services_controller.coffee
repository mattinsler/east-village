import 'ApiController'

forever = require 'forever'
Services = Caboose.path.lib.join('services').require()

class ApiServicesController extends ApiController
  index: ->
    Services.list (err, list) =>
      return @error(err) if err?
      @render(json: list.running.concat(list.not_running))
  
  stop: ->
    forever.stop(@params.services_id, false)
    @render(json: {status: 'ok'})
  
  start: ->
    svc_config = Services.config[@params.services_id]
    return @render(json: {status: 'fail', error: "Invalid service name: #{@params.services_id}"}) unless svc_config?
    
    Services.start_service svc_config, (err) =>
      return @render(json: {status: 'fail', error: err.message}) if err?
      @render(json: {status: 'ok'})
  
  restart: ->
    forever.restart(@params.services_id, false)
    @render(json: {status: 'ok'})
  
  logs: ->
    forever.tail @params.services_id, (err, proc) =>
      @render(json: {status: 'ok', logs: proc[0].logs.join('\n')})
