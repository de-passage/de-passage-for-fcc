# ###########
#   Imports #
# ###########

express = require 'express'
path = require 'path'
mongo = require('mongodb').MongoClient
body_parser = require('body-parser')

# ##############
# Declarations #
# ##############

app = express()
port = process.env.PORT
user = process.env.DB_USER
password = process.env.DB_PASSWORD
db_url = "mongodb://#{user}:#{password}@ds149551.mlab.com:49551/all-things-fcc"
db = null

# ###########
# Functions #
# ###########




# ################
# Express config #
# ################

app.set 'views', 'app/views'
app.set 'view engine', 'pug'

app.use body_parser.json()
app.use body_parser.urlencoded extended: true

app.use '/styles', express.static path.join __dirname, '../../public/styles'

# ########
# Routes #
# ########


app.get "/", (req, res) -> render "index.pug"


mongo.connect db_url, (err, database) ->
  throw err if err
  db = database
  console.log "Connected to database successfully"
  app.listen port
  console.log "Listening to port #{port}"
