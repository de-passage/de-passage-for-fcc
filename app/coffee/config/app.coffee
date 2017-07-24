express = require 'express'
path = require 'path'
body_parser = require('body-parser')
cookieParser = require "cookie-parser"
session = require "cookie-session"
passport = require "passport"
flash = require "connect-flash"
methodOverride = require "method-override"
morgan = require "morgan"
yelp = require "./yelp_auth.js"
yelp()

app = express()
expressWs = require("express-ws")(app)

secret = process.env.SECRET || "secret key here"

if process.env.DEVELOPMENT_ENV
  app.use morgan("combined")

app.use methodOverride("_method")

app.set 'views', 'app/views'
app.set 'view engine', 'pug'

app.use session secret: secret, name: "session"#, resave: false, saveUninitialized: false
app.use body_parser.json()
app.use body_parser.urlencoded extended: true
app.use cookieParser()
app.use passport.initialize()
app.use passport.session()
app.use flash()

app.use '/styles', express.static path.join __dirname, '../../../public/styles'
app.use '/scripts', express.static path.join __dirname, '../../../public/javascript'

app.use (req, res, next) ->
  if req.user?
    res.locals.user = req.user
  res.locals.url = encodeURIComponent req.url
  res.locals.path = app.locals.path
  next()

# app.use(flash({ locals: 'flash' })) should be the way to go but
# it didn't seem to fit the current code and the following was
# readily available
app.use (req, res, next) ->
  render = res.render
  f = req.flash()
  res.render = (view, options) ->
    options ?= {}
    options.flash = f
    render.call res, view, options
  next()

module.exports = app
