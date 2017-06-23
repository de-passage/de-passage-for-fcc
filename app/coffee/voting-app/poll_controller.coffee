redirectOnDBError = (err, route) ->
  if err
    flash "error", "An unexpected error has occured when calling the database: #{JSON.stringify err}"
    redirect route
    true
  else false
redirectUnlessFound = (poll, name) ->
  if !poll
    flash "error", "Poll '#{name}' not found"
    redirect "/voting-app/polls"
    true
  else false


module.exports = (Poll) ->

  show: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/polls"
      return if redirectUnlessFound poll, req.params.name
      res.render "polls/show.pug", poll: poll, user: req.user, flash: req.flash()

  create: (req, res) ->
    { name, description, options } = req.body
    if options?
      options = Array.slice.call(options)
    poll = new Poll(req.user.name, name, description, options)
    poll.save (err, poll) ->
      return if redirectOnDBError err, "/voting-app/polls/new"

#      req.flash "success", "The poll '#{poll.name}' has been created"
      res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}"

  new: (req, res) ->
    res.render "polls/new.pug", user: req.user, flash: req.flash()

  edit: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent poll.name}"
      return if redirectUnlessFound poll, req.params.name

      res.render "polls/edit.pug", user: req.user, poll: poll, flash: req.flash()

  index: (req, res) ->
    Poll.all (err, polls) ->
      return if redirectOnDBError err, "/"
      res.render "polls/index.pug", user: req.user, polls: polls, flash: req.flash()

  update: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent req.params.name}"

      { name, description, options } = req.body
      poll.save (err, poll) ->
        return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent poll.name}/edit"
        req.flash "success", "The poll '#{poll.name}' has been updated"
        res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}/edit"


  destroy: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent req.params.name}"
      return if redirectUnlessFound poll, req.params.name

      if poll.user != req.user.name
        req.flash("error", "You are not authorized to perform this action")
        return res.redirect "/voting-app"
      poll.delete()
      req.flash "success", "The poll '#{poll.name}' has been deleted"
      res.redirect "/voting-app/polls"
