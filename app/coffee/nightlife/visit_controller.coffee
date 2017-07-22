module.exports = (User) ->
  authentication = require "../authentication.js"
  before: (req, res, next) ->
    console.log "called"
    if req.user
      next()
    else
      res.status(403).json error: "You need to be authenticated to access this page"
  update: (req, res) ->
    id = req.params.venues_id
    req.user.visit = id
    req.user.save ->
      User.aggregateVisits([id]).then (visits) ->
        res.json
          visits: visits[id]

  destroy: (req, res) ->
    id = req.params.venues_id
    req.user.visit = null
    req.user.save ->
      User.aggregateVisits([id]).then (visits) ->
        res.json
          visits: visits[id]


