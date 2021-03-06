app = require "./config/app.js"

router = require "./config/router.js"
router.use app

port = process.env.PORT || 8080

multer = require 'multer'
upload = multer()

db_connection = require "./config/db.js"

db_connection (db) ->

  authentication = require("./authentication.js") db
  imgsrch = require("./imgsrch/main.js") db
  Poll = require("./voting-app/poll.js") db.collection("polls"), require("mongodb").ObjectId
  User = require("./user.js")(db.collection("users"))
  venue_controller = require('./nightlife/venue_controller.js')(User)
  visits_controller = require("./nightlife/visit_controller.js")(User)
  voting = require("./voting-app/poll_controller.js")(Poll)
  voting_options = require("./voting-app/option_controller.js")(Poll)
  market_controller = require("./market/market_controller.js")(app.wss)

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
  app.post "/voting-app/polls/vote", voting.vote
  app.post "/voting-app/polls/:name/options", authentication.isAuthenticated, voting_options.create

  # Nightlife coordinator
  router.scope "nightlife", (router) ->
    router.get "nightlife_autocomplete", "/search", venue_controller.search
    router.resource "venues", venue_controller, (router) ->
      router.resource "visits", visits_controller

  # Market mapping
  router.scope "market", (router) ->
    router.get "market_root", "/", market_controller.show
    router.addRoute "marketWS", "ws", "/ws", market_controller.webSocket


  # Authentication
  app.get "/login", (req, res) -> res.render "login.pug", redirect: req.query.redirect
  app.post "/login", authentication.login, (req, res) -> res.redirect if req.body.redirect then req.body.redirect else "/profile"

  app.get "/signup", (req, res) -> res.render "signup.pug"
  app.post "/signup", authentication.signup

  app.get "/logout", authentication.logout

  # User profile
  app.get "/profile", authentication.isAuthenticated, (req, res) ->
    Poll.find owner: req.user.name, (err, polls) ->
      res.render "profile.pug", polls: polls



  # Start the application
  app.listen port
  console.log "Listening to port #{port}"
  console.log "Paths: ", Object.keys app.locals.path
