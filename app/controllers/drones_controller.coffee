import 'ApplicationController'
import 'TerminalColorsHelper'

_ = require 'underscore'
forever = require 'forever'
drones = Caboose.path.lib.join('drones').require()

class DronesController extends ApplicationController
  helper TerminalColorsHelper
  
  index: ->
    drones.list (err, procs) =>
      @drones = procs
      @render()
  
  stop: ->
    forever.stop(@params.drones_id, false)
    @redirect_to '/drones'
  
  restart: ->
    # forever.restart(@params.drones_id, false)
    @redirect_to '/drones'
  
  logs: ->
    forever.tail @params.drones_id, (err, proc) =>
      @logs = proc[0].logs.join('\n')
      @render()
