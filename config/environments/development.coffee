module.exports = (config, next) ->
  
  config.axle = {
    port: 2020
  }
  
  next()
