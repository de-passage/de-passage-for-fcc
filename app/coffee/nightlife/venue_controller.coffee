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

    request = https.get
      host: url
      path: path
      headers:
        "Authorization": "Bearer " + token
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
            if Array.isArray res.locals.flash["error"]
              res.locals.flash["error"].push e.message
            else
              res.locals.flash["error"] = e.message
            res.render view
        resp.on "error", (err) ->
          if Array.isArray res.locals.flash["error"]
            res.locals.flash["error"].push e.message
          else
            res.locals.flash["error"] = e.message
          res.render view
    request.on "error", (e) ->
      console.log "Error with request to access the Yelp Business API", e.message
      if Array.isArray res.locals.flash["error"]
        res.locals.flash["error"].push err.message
      else
        res.locals.flash["error"] = err.message
    request.end()

  index: (req, res) ->
    { type, longitude, latitude, location } = req.query
    view = "venues/index.pug"

    if (longitude? and latitude?) or location?
      params = []
      for param in [ "longitude", "latitude", "location", "term" ]
        if req.query[param]?
          params.push param + "=" + encodeURIComponent req.query[param]

      params.push "categories=bars"

      url = "api.yelp.com"
      path = "/v3/businesses/search?" + params.join("&")
      token = cache.get("yelp_token")

      request = https.get
        host: url
        path: path
        headers:
          "Authorization": "Bearer " + token
        (resp) ->
          rawData = ""
          resp.on "data", (chunk) -> rawData += chunk
          resp.on "end", ->
            try
              parsedData = JSON.parse rawData
              venues = (business.id for business in parsedData.businesses)
              User.aggregateVisits(venues).then((results) ->
                for business in parsedData.businesses
                  business.going = results[business.id].length
                  business.user_going = req.user? and (req.user.visit == business.id)
                if type == "json"
                  res.json(parsedData)
                else
                  res.render view, yelpData: parsedData
              )
            catch e
              if type == "json"
                res.status(500).json e
              else
                if Array.isArray res.locals.flash["error"]
                  res.locals.flash["error"].push e.message
                else
                  res.locals.flash["error"] = e.message
                res.render view
      request.on "error", (err) ->
        if type == "json"
          res.status(500).json(err)
        else
          if Array.isArray res.locals.flash["error"]
            res.locals.flash["error"].push err.message
          else
            res.locals.flash["error"] = err.message
          res.render view
      request.end()
    else
      if "json" == type
        res.json {}
      else
        res.render view

  search: (req, res) ->
    params = []
    for param in [ "longitude", "latitude", "text" ]
      if req.query[param]?
        params.push param + "=" + encodeURIComponent req.query[param]
    url = "api.yelp.com"
    path = "/v3/autocomplete?" + params.join("&")
    token = cache.get("yelp_token")
    request = https.get
      host: url
      path: path
      headers:
        "Authorization": "Bearer " + token
      (resp) ->
        rawData = ""
        resp.on "data", (chunk) -> rawData += chunk
        resp.on "end", ->
          try
            parsedData = JSON.parse rawData
            res.json parsedData
    request.on "error", (err) ->
      console.log "Error with the request to access the Yelp Autocomplete API: ", err.message
      res.status(500).json err
    request.end()

    
