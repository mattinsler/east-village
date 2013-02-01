module.exports = (config, next) ->
  config.http =
    enabled: true
    port: process.env.PORT || 3000
  
  config.session_secret = 'some kind of random string'

  next()
