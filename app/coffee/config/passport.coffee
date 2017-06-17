passport = require "passport"
ObjectId = require("mongodb").ObjectId
LocalStrategy = require("passport-local").Strategy


module.exports = (User) ->
  passport.serializeUser (user, done) ->
    done null, user.id

  passport.deserializeUser (id, done) ->
    User.findOne _id: ObjectId(id), (err, user) ->
      if err then done err else done null, user


  passport.use "local-login", new LocalStrategy {
      usernameField: 'email'
      passReqToCallback: true
    }, (req, email, password, done) ->
      User.findOne email: email, (err, user) ->
        return done err if err
        return done null, false, req.flash("loginMessage", "The email address or password is incorrect") unless user and user.verifyPassword password
        done null, user

  passport.use "local-signup", new LocalStrategy {
        usernameField: 'email'
        passReqToCallback: true
      }, (req, email, password, done) ->
        User.findOne $or: [{email: email}, {username: req.body.username}] , (err, user) ->
          return done err if err
          return done null, false, req.flash('signupMessage', "This email adress is already taken") if user
          newUser = new User(req.body.username, email, {})
          newUser.setPassword(password)
          newUser.save done

  passport
