# ###########
#   Imports #
# ###########

express = require 'express'
path = require 'path'
mongo = require('mongodb').MongoClient
body_parser = require('body-parser')
https = require('https')
util = require 'util'
multer = require 'multer'
passport = require "passport"
LocalStrategy = require("passport-local").Strategy
cookieParser = require "cookie-parser"
session = require "express-session"

# ##############
# Declarations #
# ##############

upload = multer()
app = express()
port = process.env.PORT || 8080
user = process.env.DB_USER
password = process.env.DB_PASSWORD
secret = process.env.SECRET || "secret key here"
db_url = "mongodb://#{user}:#{password}@ds149551.mlab.com:49551/all-things-fcc"
google_api_key = process.env.GOOGLE_API_KEY
db = null

# ###########
# Functions #
# ###########

searchImages = (searchparams, offset, callback) ->
  https.get "https://www.googleapis.com/customsearch/v1?key=#{google_api_key}&cx=013364742045618430023:l_tcw48e2pw&q=#{encodeURIComponent searchparams}&searchType=image&start=#{offset}", (res) ->
    { statusCode } = res
    if statusCode != 200
      callback { status: statusCode, msg: "Request failed", response: res }
    else
      rawData = ""
      res.on "data", (chunks) => rawData += chunks
      res.on "end", =>
        try
          parsedData = JSON.parse rawData
          callback null, parsedData
        catch e
          callback e

# #################
# Passport config #
# #################

passport.use new LocalStrategy (username, password, done) ->
  User.find username: username, (err, user) ->
    return done err if err
    return done null, false unless user and user.verifyPassword password
    done null, user

passport.serializeUser (user, done) -> done null, user.id

passport.deserializeUser (id, done) ->
  User.find id: id, (err, user) ->
    if err then done err else done null, user

# ################
# Express config #
# ################

app.set 'views', 'app/views'
app.set 'view engine', 'pug'

app.use body_parser.json()
app.use body_parser.urlencoded extended: true
app.use cookieParser()
app.use session secret: secret, resave: false, saveUninitialized: false

app.use '/styles', express.static path.join __dirname, '../../public/styles'

# ########
# Routes #
# ########


app.get "/", (req, res) -> res.render "index.pug"

app.get "/imgsrch", (req, res) -> res.render "imgsrch.pug"

app.get "/imgsrch/search/:search", (req, res) ->
  { search } = req.params
  { offset } = req.query
  offset ?= 0
  offset = offset * 10 + 1
  db.collection("imgsearch").insert search: search, date: Date.now()
  searchImages search, offset, (err, result) ->
    throw err if err
    searchResult = (url: img.link, snippet: img.snippet, context: img.image.contextLink, thumbnail: img.image.thumbnailLink for img in result.items)
    res.json searchResult

app.get "/imgsrch/latest", (req, res) ->
  db.collection("imgsearch").find({}, { sort: [[ "date", 'descending' ]] }).limit(10).toArray (err, result) ->
    throw err if err
    queryResult = ( search: r.search, date: r.date, dateStr: (new Date(r.date)).toString() for r in result )
    res.json queryResult

app.get "/filedata", (req, res) -> res.render "filesize.pug"

app.post "/filedata", upload.single('file'), (req, res) ->
  res.json size: req.file.size

app.get "/login", (req, res) -> res.render "login.pug"
app.post "/login", (req, res) ->

app.get "/signup", (req, res) -> res.render "signin.pug"
app.post "/signup", (req, res) ->

mongo.connect db_url, (err, database) ->
  throw err if err
  db = database
  console.log "Connected to database successfully"
  app.listen port
  console.log "Listening to port #{port}"
