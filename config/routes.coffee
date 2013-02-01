module.exports = ->
  @route '/', 'application#index'
  
  @namespace '/auth', ->
    @route 'logout', 'auth#logout'
    @route 'github', 'auth#github'
    @route 'github/callback', 'auth#github_callback'
  
  @resources 'projects', ->
    @route 'update_code', 'projects#update_code'
    
    @resources 'versions', ->
      @route 'install_dependencies', 'versions#install_dependencies'
      @route 'start', 'versions#start'
      @route 'stop', 'versions#stop'
  
  
  
  @resources 'services', ->
    @route 'logs', 'services#logs'
  
  @resources 'drones'
  
  
  
  
  @namespace 'api', ->
    @resources 'repos', 'api_repos'
    
    @resources 'drones', 'api_drones', ->
      @route 'clone', 'api_drones#clone'
    
    @resources 'services', 'api_services', ->
      @route 'stop', 'api_services#stop'
      @route 'start', 'api_services#start'
      @route 'logs', 'api_services#logs'
