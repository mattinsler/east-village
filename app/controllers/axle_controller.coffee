import 'ApplicationController'

_ = require 'underscore'
net = require 'net'

class AxleController extends ApplicationController
  index: ->
    client = net.connect 1313, =>
      client.write(JSON.stringify($c: 'routes', $d: null))
      client.on 'data', (data) =>
        @routes = JSON.parse(data.toString())
        client.end()
        @render()
