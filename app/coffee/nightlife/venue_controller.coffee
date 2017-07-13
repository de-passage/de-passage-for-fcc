yelpAuthentication = (req, res, next) ->
  next()

module.exports = (User) ->
  before: [
    yelpAuthentication
  ]

  show: (req, res) ->
    res.render("venues/show.pug")

  index: (req, res) ->
    res.render("venues/index.pug")
