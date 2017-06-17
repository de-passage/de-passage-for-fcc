// Generated by CoffeeScript 1.9.3
(function() {
  module.exports = function(db) {
    var User, passport;
    User = require("./user.js")(db.collection("users"));
    passport = require("./config/passport.js")(User);
    return {
      login: passport.authenticate("local-login", {
        successRedirect: "/profile",
        failureRedirect: "/login",
        failureFlash: true
      }),
      signup: passport.authenticate("local-signup", {
        successRedirect: "/profile",
        failureRedirect: "/signup",
        failureFlash: true
      }),
      logout: function(req, res) {
        req.logout();
        return res.redirect("/");
      },
      isAuthenticated: function(req, res, next) {
        if (req.isAuthenticated()) {
          return next();
        }
        req.flash("loginMessage", "You need to authenticate to access this page");
        return res.redirect("/login");
      }
    };
  };

}).call(this);
