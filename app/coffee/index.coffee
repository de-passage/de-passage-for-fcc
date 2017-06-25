app = require "./config/app.js"
port = process.env.PORT || 8080

multer = require 'multer'
upload = multer()

db_connection = require "./config/db.js"

db_connection (db) ->

  authentication = require("./authentication.js") db
  imgsrch = require("./imgsrch/main.js") db
  Poll = require("./voting-app/poll.js") db.collection("polls"), require("mongodb").ObjectId
  voting = require("./voting-app/poll_controller.js")(Poll)

  # ########
  # Routes #
  # ########

  # Root #
  app.get "/", (req, res) -> res.render "index.pug"

  # Image search API #
  app.get "/imgsrch", (req, res) -> res.render "imgsrch.pug"

  app.get "/imgsrch/search/:search", imgsrch.search
  app.get "/imgsrch/latest", imgsrch.latest

  # File Metadata microservice #
  app.get "/filedata", (req, res) -> res.render "filesize.pug"

  app.post "/filedata", upload.single('file'), (req, res) ->
    res.json size: req.file.size

  # Voting app
  app.get "/voting-app", (req, res) -> res.redirect "/voting-app/polls"
  app.get "/voting-app/polls", voting.index
  app.get "/voting-app/poll/:name", voting.show
  app.get "/voting-app/poll/:name/edit", authentication.isAuthenticated, voting.edit
  app.put "/voting-app/poll/:name", authentication.isAuthenticated,  voting.update
  app.get "/voting-app/polls/new", authentication.isAuthenticated,  voting.new
  app.post "/voting-app/poll", authentication.isAuthenticated,  voting.create
  app.delete "/voting-app/poll/:name", authentication.isAuthenticated,  voting.destroy

  # Authentication
  app.get "/login", (req, res) -> res.render "login.pug", flash: req.flash(), user: req.user, redirect: req.query.redirect
  app.post "/login", authentication.login, (req, res) -> res.redirect if req.body.redirect then req.body.redirect else "/profile"

  app.get "/signup", (req, res) -> res.render "signup.pug", flash: req.flash(), user: req.user
  app.post "/signup", authentication.signup

  app.get "/logout", authentication.logout

  # User profile
  app.get "/profile", authentication.isAuthenticated, (req, res) -> res.render "profile.pug", user: req.user, flash: req.flash


  # Start the application
  app.listen port
  console.log "Listening to port #{port}"
