passport = Caboose.app.passport = require 'passport'
GitHubStrategy = require('passport-github').Strategy

passport.serializeUser (user, done) ->
  done(null, user._id)

passport.deserializeUser (id, done) ->
  User = Caboose.get('User')
  
  User.where(_id: id).first (err, user) ->
    return done(err) if err?
    done(null, user)

passport.use(
  new GitHubStrategy {
    clientID: 'e37eea20e177cd82f342',
    clientSecret: 'f5307c0a79ab125f4e8aa826456c2e836689002b',
    callbackURL: "http://east-village.localhost.dev/auth/github/callback"
  }, (access_token, refresh_token, profile, done) ->
    User = Caboose.get('User')
    
    profile.access_token = access_token
    User.upsert {'accounts.github.id': profile.id}, {$set: {'accounts.github': profile}}, (err) ->
      return done(err) if err?
    
      User.where('accounts.github.id': profile.id).first (err, user) ->
        return done(err) if err?
        done(null, user)
)
