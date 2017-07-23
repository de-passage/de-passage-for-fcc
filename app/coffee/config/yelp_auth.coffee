cache = require "memory-cache"
https = require "https"
querystring = require "querystring"

authenticate = ->
  cache.put "test", "Stored"
  data = querystring.stringify
    grant_type: "client_credentials"
    client_id: process.env.YELP_ID || throw "Error: yelp ID not provided"
    client_secret: process.env.YELP_SECRET || throw "Error: yelp secret not provided"

  req = https.request {
    method: "POST"
    host: "api.yelp.com"
    path: "/oauth2/token"
    port: process.env.PORT
    headers:
      "Content-Type": "application/x-www-form-urlencoded"
      "Content-Length": Buffer.byteLength(data)
    },
    (res) ->
      res.setEncoding("utf-8")
      res.on "data", (chunk) ->
        ret = JSON.parse chunk
        console.log "Fetched new yelp authentication token. Expires in #{ret.expires_in} seconds"
        cache.put("yelp_token", ret.access_token, Math.min(ret.expires_in * 1000, 2147483647), authenticate)
      res.on "end", ->
        console.log "Yelp auth end"
      res.on "error", (data...) ->
        console.log "Error getting yelp authentication token:", data...

  req.write data
  req.end()

module.exports = authenticate
