cache = require "memory-cache"
https = require "https"

authenticate = ->
  https.request
    method: "POST"
    hostname: "https://api.yelp.com/oauth2/token"

module.exports = authenticate
