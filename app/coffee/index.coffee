app = require "./config/app.js"
port = process.env.PORT || 8080

multer = require 'multer'
upload = multer()

db_connection = require "./config/db.js"

db_connection (db) ->

  authentication = (require "./authentication.js") db
  imgsrch = (require "./imgsrch/main.js") db

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
  
  # Authentication
  app.get "/login", (req, res) -> req.user; res.render "login.pug", message: req.flash("loginMessage"), user: req.user
  app.post "/login", authentication.login

  app.get "/signup", (req, res) -> res.render "signup.pug", message: req.flash("signupMessage"), user: req.user
  app.post "/signup", authentication.signup
  
  app.get "/logout", authentication.logout
  app.get "/profile", authentication.isAuthenticated, (req, res) -> res.render "profile.pug", user: req.user


  # Start the application
  app.listen port
  console.log "Listening to port #{port}"
