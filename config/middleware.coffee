express = require 'express'
flash = require 'connect-flash'
compiler = require 'connect-compiler'
passport = Caboose.app.passport
RedisStore = require('connect-redis')(express)

Caboose.app.session_store = new RedisStore()

module.exports = (http) ->
  http.use express.bodyParser()
  http.use express.methodOverride()
  http.use express.cookieParser()
  http.use express.session(store: Caboose.app.session_store, secret: Caboose.app.config.session_secret)
  http.use passport.initialize()
  http.use passport.session()
  http.use flash()
  http.use -> Caboose.app.router.route.apply(Caboose.app.router, arguments)
  http.use compiler(
    enabled: ['coffee']
    src: 'public'
    dest: 'public_compiled'
  )
  http.use express.static Caboose.root.join('public_compiled').path
  http.use express.static Caboose.root.join('public').path
