cache = require "memory-cache"
https = require "https"

fetchYelpData = (req, res) ->

module.exports = (User) ->
  show: (req, res) ->
    res.render("venues/show.pug")

  index: (req, res) ->
    { type, longitude, latitude, location } = req.query
    view = "venues/index.pug"

    if (longitude? and latitude?) or location?
      console.log "here"
      params = []
      for param in [ "longitude", "latitude", "location" ]
        if req.query[param]?
          params.push param + "=" + req.query[param]

      url = "api.yelp.com"
      path = "/v3/businesses/search?" + params.join("&")
      token = cache.get("yelp_token")

      https.get
        host: url
        path: path
        headers:
          "Authorization": "Bearer " + token
        port: process.env.PORT
        (resp) ->
          rawData = ""
          resp.on "data", (chunk) -> rawData += chunk
          resp.on "end", ->
            try
              parsedData = JSON.parse rawData
              if type == "json"
                res.json(parsedData)
              else
                res.render view, yelpData: parsedData

            catch e
              if type == "json"
                res.status(500).json e
              else
                if Array.isArray app.locals.flash["error"]
                  app.locals.flash["error"].push e.message
                else
                  app.locals.flash["error"] = e.message
                res.render view
          resp.on "error", (err) ->
            if type == "json"
              res.status(500).json(err)
            else
              if Array.isArray app.locals.flash["error"]
                app.locals.flash["error"].push e.message
              else
                app.locals.flash["error"] = e.message
              res.render view
    else
      if "json" == type
        res.json {}
      else
        res.render view
