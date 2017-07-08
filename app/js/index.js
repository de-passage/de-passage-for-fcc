// Generated by CoffeeScript 1.9.3
(function() {
  var app, db_connection, multer, port, upload;

  app = require("./config/app.js");

  port = process.env.PORT || 8080;

  multer = require('multer');

  upload = multer();

  db_connection = require("./config/db.js");

  db_connection(function(db) {
    var Poll, authentication, imgsrch, voting, voting_options;
    authentication = require("./authentication.js")(db);
    imgsrch = require("./imgsrch/main.js")(db);
    Poll = require("./voting-app/poll.js")(db.collection("polls"), require("mongodb").ObjectId);
    voting = require("./voting-app/poll_controller.js")(Poll);
    voting_options = require("./voting-app/option_controller.js")(Poll);
    app.get("/", function(req, res) {
      return res.render("index.pug");
    });
    app.get("/imgsrch", function(req, res) {
      return res.render("imgsrch.pug");
    });
    app.get("/imgsrch/search/:search", imgsrch.search);
    app.get("/imgsrch/latest", imgsrch.latest);
    app.get("/filedata", function(req, res) {
      return res.render("filesize.pug");
    });
    app.post("/filedata", upload.single('file'), function(req, res) {
      return res.json({
        size: req.file.size
      });
    });
    app.get("/voting-app", function(req, res) {
      return res.redirect("/voting-app/polls");
    });
    app.get("/voting-app/polls", voting.index);
    app.get("/voting-app/poll/:name", voting.show);
    app.get("/voting-app/poll/:name/edit", authentication.isAuthenticated, voting.edit);
    app.put("/voting-app/poll/:name", authentication.isAuthenticated, voting.update);
    app.get("/voting-app/polls/new", authentication.isAuthenticated, voting["new"]);
    app.post("/voting-app/poll", authentication.isAuthenticated, voting.create);
    app["delete"]("/voting-app/poll/:name", authentication.isAuthenticated, voting.destroy);
    app.post("/voting-app/polls/vote", voting.vote);
    app.post("/voting-app/polls/:name/options", authentication.isAuthenticated, voting_options.create);
    app.get("/login", function(req, res) {
      return res.render("login.pug", {
        flash: req.flash(),
        user: req.user,
        redirect: req.query.redirect
      });
    });
    app.post("/login", authentication.login, function(req, res) {
      return res.redirect(req.body.redirect ? req.body.redirect : "/profile");
    });
    app.get("/signup", function(req, res) {
      return res.render("signup.pug", {
        flash: req.flash(),
        user: req.user
      });
    });
    app.post("/signup", authentication.signup);
    app.get("/logout", authentication.logout);
    app.get("/profile", authentication.isAuthenticated, function(req, res) {
      return res.render("profile.pug", {
        user: req.user,
        flash: req.flash
      });
    });
    app.listen(port);
    return console.log("Listening to port " + port);
  });

}).call(this);
