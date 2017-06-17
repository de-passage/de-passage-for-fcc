mongo = require('mongodb').MongoClient

user = process.env.DB_USER
password = process.env.DB_PASSWORD
db_url = "mongodb://#{user}:#{password}@ds149551.mlab.com:49551/all-things-fcc"

connect = (callback) ->
  mongo.connect db_url, (err, database) ->
    throw err if err
    db = database
    console.log "Connected to database successfully"
    callback db

module.exports = connect
