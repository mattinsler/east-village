cookie = require 'cookie'
connect = require 'connect'
passport = require 'passport'

passport_socketio = (io, opts = {}) ->
  throw new Error('Must supply session_store to passport and socket.io integration') unless opts.session_store?
  throw new Error('Must supply session_secret to passport and socket.io integration') unless opts.session_secret?
  
  opts.session_key ?= 'connect.sid'
  
  io.configure ->
    io.set 'authorization', (handshake_data, callback) ->
      return callback('No cookie', false) unless handshake_data.headers.cookie?
      
      handshake_data.cookie = cookie.parse(handshake_data.headers.cookie)
      handshake_data.cookie = connect.utils.parseSignedCookies(handshake_data.cookie, opts.session_secret)
      handshake_data.session_id = handshake_data.cookie[opts.session_key]
      
      opts.session_store.load handshake_data.session_id, (err, session) ->
        return callback(err.message, false) if err?
        return callback('No session', false) unless session?
        return callback('Passport was not initialized', false) unless session[passport._key]?
        user_id = session[passport._key][passport._userProperty or 'user']
        return callback('No user', false) unless user_id?
        
        handshake_data.session = session
        
        passport.deserializeUser user_id, (err, user) ->
          return callback(err.message, false) if err?
          return callback('No user', false) unless user?
          
          handshake_data.user = user
          callback(null, true)
  
  io.sockets.on 'connection', (socket) ->
    console.log 'connected'
    socket.user = socket.handshake.user

module.exports = passport_socketio
