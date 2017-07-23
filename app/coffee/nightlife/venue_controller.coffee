cache = require "memory-cache"
https = require "https"

fetchYelpData = (req, res) ->

module.exports = (User) ->

  show: (req, res) ->
    id = req.params.venues_id
    view = "venues/show.pug"
    url = "api.yelp.com"
    path = "/v3/businesses/#{id}"
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
            User.aggregateVisits([id]).then (arr) ->
              parsedData.visits = arr
              res.render view, yelpData: parsedData
          catch e
            if Array.isArray app.locals.flash["error"]
              app.locals.flash["error"].push e.message
            else
              app.locals.flash["error"] = e.message
            res.render view
        resp.on "error", (err) ->
          if Array.isArray app.locals.flash["error"]
            app.locals.flash["error"].push e.message
          else
            app.locals.flash["error"] = e.message
          res.render view

  index: (req, res) ->
    { type, longitude, latitude, location } = req.query
    view = "venues/index.pug"

    if (longitude? and latitude?) or location?
      params = []
      for param in [ "longitude", "latitude", "location", "term" ]
        if req.query[param]?
          params.push param + "=" + encodeURIComponent req.query[param]

      url = "api.yelp.com"
      path = "/v3/businesses/search?" + params.join("&")
      token = cache.get("yelp_token")

      https.get
        host: url
        path: path
        headers:
          "Authorization": "Bearer " + token
        #port: process.env.PORT
        (resp) ->
          rawData = ""
          resp.on "data", (chunk) -> rawData += chunk
          resp.on "end", ->
            try
              parsedData = JSON.parse rawData
              venues = (business.id for business in parsedData.businesses)
              User.aggregateVisits(venues).then((results) ->
                business.going = results[business.id].length for business in parsedData.businesses
                if type == "json"
                  res.json(parsedData)
                else
                  res.render view, yelpData: parsedData
              )
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

  search: (req, res) ->
    console.log "called"
    params = []
    for param in [ "longitude", "latitude", "text" ]
      if req.query[param]?
        params.push param + "=" + encodeURIComponent req.query[param]
    url = "api.yelp.com"
    path = "/v3/autocomplete?" + params.join("&")
    token = cache.get("yelp_token")
    https.get
      host: url
      path: path
      headers:
        "Authorization": "Bearer " + token
      #port: process.env.PORT
      (resp) ->
        rawData = ""
        resp.on "data", (chunk) -> rawData += chunk
        resp.on "end", ->
          try
            parsedData = JSON.parse rawData
            res.json parsedData

    
