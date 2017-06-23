express = require 'express'
path = require 'path'
body_parser = require('body-parser')
cookieParser = require "cookie-parser"
session = require "express-session"
passport = require "passport"
flash = require "connect-flash"
methodOverride = require "method-override"
morgan = require "morgan"

app = express()

secret = process.env.SECRET || "secret key here"

app.use morgan("combined")

app.use methodOverride("_method")

app.set 'views', 'app/views'
app.set 'view engine', 'pug'

app.use body_parser.json()
app.use body_parser.urlencoded extended: true
app.use cookieParser()
app.use session secret: secret, resave: false, saveUninitialized: false
app.use passport.initialize()
app.use passport.session()
app.use flash()

app.use '/styles', express.static path.join __dirname, '../../../public/styles'
app.use '/scripts', express.static path.join __dirname, '../../../public/javascript'

module.exports = app
