return unless Caboose.command is 'server'

io = require 'socket.io'
passport_socketio = Caboose.path.lib.join('passport_socketio').require()

Caboose.app.after 'boot', ->
  Caboose.app.io = io = io.listen(Caboose.app.raw_http)
  passport_socketio(io,
    session_store: Caboose.app.session_store
    session_secret: Caboose.app.config.session_secret
  )
  
  io.sockets.on 'connection', (socket) ->
    socket.join(socket.user._id)
