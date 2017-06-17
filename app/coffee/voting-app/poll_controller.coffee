module.exports = (db) ->
  Poll = require("./poll.js") db

  show: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      req.render "show_poll.pug", poll: poll, user: req.user

  create: (req, res) ->
    { name, description, options } = req.body
    poll = new Poll(req.user.name, name, description, options)
    poll.save (err, poll) ->
      return req.redirect "/voting-app/polls/new" if err
      req.redirect "/voting-app/poll/#{encodeURIComponent poll.name}"

  new: (req, res) ->
    req.render "new_poll.pug", user: req.user
  
  edit: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      req.render "edit_poll.pug", user: req.user, poll: poll

  index: (req, res) ->
    Poll.all (err, polls) ->
      req.render "index_polls.pug", user: req.user, polls: polls

  update: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      req.redirect "/voting-app/poll/#{encodeURIComponent poll.name}/edit"


  destroy: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      poll.delete()
