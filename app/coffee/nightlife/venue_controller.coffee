module.exports = (User) ->
	show: (req, res) ->
      res.render("venues/show.pug")

    index: (req, res) ->
      res.render("venues/index.pug")


