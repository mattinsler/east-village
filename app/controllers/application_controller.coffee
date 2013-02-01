_ = require 'underscore'
_.str = require 'underscore.string'

class ApplicationController extends Controller
  helper {
    _: _
    moment: require('moment')
  }
  
  before_action (next) ->
    @current_user = @request.user
    next()
  
  index: ->
    # @render()
    return @render() unless @current_user?
    @redirect_to '/projects'
