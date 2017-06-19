module.exports = (Poll) ->

  show: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      res.render "show_poll.pug", poll: poll, user: req.user

  create: (req, res) ->
    { name, description, options } = req.body
    poll = new Poll(req.user.name, name, description, options)
    poll.save (err, poll) ->
      return res.redirect "/voting-app/polls/new" if err
      res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}"

  new: (req, res) ->
    res.render "new_poll.pug", user: req.user
  
  edit: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      res.render "edit_poll.pug", user: req.user, poll: poll

  index: (req, res) ->
    Poll.all (err, polls) ->
      res.render "index_polls.pug", user: req.user, polls: polls

  update: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}/edit"


  destroy: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      poll.delete()
      res.redirect "/voting-app/polls"
