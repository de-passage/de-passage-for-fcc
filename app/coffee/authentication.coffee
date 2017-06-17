module.exports = (db) ->
  User = require("./user.js") db.collection("users")
  passport = require("./config/passport.js") User


  login:
    passport.authenticate "local-login",
      successRedirect: "/profile"
      failureRedirect: "/login"
      failureFlash: true

  signup:
    passport.authenticate "local-signup",
      successRedirect: "/profile"
      failureRedirect: "/signup"
      failureFlash: true

  logout:
    (req, res) ->
      req.logout()
      res.redirect("/")

  isAuthenticated:
    (req, res, next) ->
      return next() if req.isAuthenticated()
      req.flash "loginMessage", "You need to authenticate to access this page"
      res.redirect("/login")
