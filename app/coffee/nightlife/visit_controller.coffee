module.exports = (User) ->
  authentication = require "../authentication.js"
  before: authentication.isAuthenticated
  update: (req, res) ->
    id = req.params.venues_id
    req.user.visit = id
    req.user.save ->
      User.aggregateVisits([id]).then (visits) ->
        res.json
          url: res.locals.path.destroy_visits(id, "self")
          visits: visits

  destroy: (req, res) ->
    id = req.params.venues_id
    req.user.visit = null
    req.user.save ->
      User.aggregateVisits([id]).then (visits) ->
        res.json
          url: res.locals.path.update_visits(id, "self")
          visits: visits


