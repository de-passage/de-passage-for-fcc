module.exports = (Poll) ->

  show: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      res.render "polls/show.pug", poll: poll, user: req.user

  create: (req, res) ->
    { name, description, options } = req.body
    if options?
      options = Array.slice.call(options)
    poll = new Poll(req.user.name, name, description, options)
    poll.save (err, poll) ->
      return res.redirect "/voting-app/polls/new" if err
      res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}"

  new: (req, res) ->
    res.render "polls/new.pug", user: req.user
  
  edit: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      res.render "polls/edit.pug", user: req.user, poll: poll

  index: (req, res) ->
    Poll.all (err, polls) ->
      res.render "polls/index.pug", user: req.user, polls: polls

  update: (req, res) ->
    Poll.findOne name: req.body.name, (err, poll) ->
      poll.save()
      res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}/edit"


  destroy: (req, res) ->
    Poll.findOne name: req.body.name, (err, poll) ->
      poll.delete()
      res.redirect "/voting-app/polls"
