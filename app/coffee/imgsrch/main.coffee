https = require('https')
google_api_key = process.env.GOOGLE_API_KEY

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

module.exports = (db) ->

  search:
    (req, res) ->
      { search } = req.params
      { offset } = req.query
      offset ?= 0
      offset = offset * 10 + 1
      db.collection("imgsearch").insert search: search, date: Date.now()
      searchImages search, offset, (err, result) ->
        throw err if err
        searchResult = (url: img.link, snippet: img.snippet, context: img.image.contextLink, thumbnail: img.image.thumbnailLink for img in result.items)
        res.json searchResult

  latest:
    (req, res) ->
      db.collection("imgsearch").find({}, { sort: [[ "date", 'descending' ]] }).limit(10).toArray (err, result) ->
        throw err if err
        queryResult = ( search: r.search, date: r.date, dateStr: (new Date(r.date)).toString() for r in result )
        res.json queryResult


