// Generated by CoffeeScript 1.9.3
(function() {
  var app, db_connection, multer, port, upload;

  app = require("./config/app.js");

  port = process.env.PORT || 8080;

  multer = require('multer');

  upload = multer();

  db_connection = require("./config/db.js");

  db_connection(function(db) {
    var authentication, imgsrch, voting;
    authentication = (require("./authentication.js"))(db);
    imgsrch = (require("./imgsrch/main.js"))(db);
    voting = (require("./voting-app/poll_controller.js"))(db);
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
    app.get("/voting-app/polls", voting.index);
    app.get("/voting-app/poll/:name", voting.show);
    app.get("/voting-app/poll/:name/edit", voting.edit);
    app.put("voting-app/poll/:name", voting.update);
    app.get("/voting-app/polls/new", voting["new"]);
    app.post("/voting-app/poll", voting.create);
    app["delete"]("/voting-app/poll/:name", voting.destroy);
    app.get("/login", function(req, res) {
      req.user;
      return res.render("login.pug", {
        message: req.flash("loginMessage"),
        user: req.user
      });
    });
    app.post("/login", authentication.login);
    app.get("/signup", function(req, res) {
      return res.render("signup.pug", {
        message: req.flash("signupMessage"),
        user: req.user
      });
    });
    app.post("/signup", authentication.signup);
    app.get("/logout", authentication.logout);
    app.get("/profile", authentication.isAuthenticated, function(req, res) {
      return res.render("profile.pug", {
        user: req.user
      });
    });
    app.listen(port);
    return console.log("Listening to port " + port);
  });

}).call(this);
