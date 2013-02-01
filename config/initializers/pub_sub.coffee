# _ = require 'underscore'
# redback = require 'redback'
# 
# Caboose.app.channels = {
#   logs: redback.createClient().createChannel('logs')
# }
# 
# return unless Caboose.command is 'server'
# 
# channels = {
#   logs: redback.createClient().createChannel('logs').subscribe()
# }
# 
# _(channels).each (channel, type) ->
#   channel.on 'message', (items) ->
#     return unless items?
#     items = JSON.parse(items)
#     if items.room? and items.data?
#       room = items.room
#       items = items.data
#     items = [items] unless Array.isArray(items)
#     
#     if room?
#       Caboose.app.io.sockets.in(room).emit(type, items)
#     else
#       Caboose.app.io.sockets.emit(type, items)
