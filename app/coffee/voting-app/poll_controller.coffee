redirectOnDBError = (err, route, req, res) ->
  if err
    req.flash "error", "An unexpected error has occured when calling the database: #{JSON.stringify err}"
    res.redirect route
    true
  else false
redirectUnlessFound = (poll, name, req, res) ->
  if !poll
    req.flash "error", "Poll '#{name}' not found"
    res.redirect "/voting-app/polls"
    true
  else false


module.exports = (Poll) ->

  show: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/polls", req, res
      return if redirectUnlessFound poll, req.params.name, req, res
      res.render "polls/show.pug", poll: poll, user: req.user, flash: req.flash()

  create: (req, res) ->
    { name, description, options } = req.body
    if options?
      options = Array.slice.call(options)
    poll = new Poll(req.user.name, name, description, options)
    poll.save (err, poll) ->
      return if redirectOnDBError err, "/voting-app/polls/new", req, res

      res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}"

  new: (req, res) ->
    res.render "polls/new.pug", user: req.user, flash: req.flash()

  edit: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent poll.name}", req, res
      return if redirectUnlessFound poll, req.params.name, req, res

      res.render "polls/edit.pug", user: req.user, poll: poll, flash: req.flash()

  index: (req, res) ->
    Poll.all (err, polls) ->
      return if redirectOnDBError err, "/", req, res
      res.render "polls/index.pug", user: req.user, polls: polls, flash: req.flash()

  update: (req, res) ->
    { name, description, options } = req.body

    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent req.params.name}", req, res

      if(name? or description?)
        if(req.user.name == poll.user)
          poll.name = name if name?
          poll.description = description if description?
          if options?
            poll.replaceOptions options
        else
          req.flash("error", "You are not authorized to perform this action")
          return res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}"
      else if options?
        if Array.isArray options
          for option in options
            poll.addOption { description: option }, req.user.name
        else
          poll.addOption { description: options }, req.user.name


      poll.save (err, poll) ->
        return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent poll.name}/edit", req, res

        res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}"


  destroy: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent req.params.name}", req, res
      return if redirectUnlessFound poll, req.params.name

      if poll.user != req.user.name
        req.flash("error", "You are not authorized to perform this action")
        return res.redirect "/voting-app"
      poll.delete()
      req.flash "success", "The poll '#{poll.name}' has been deleted"
      res.redirect "/voting-app/polls"

  vote: (req, res) ->
    { name, option } = req.body
    user =
      if req.user.isAuthenticated()
        req.user.name
      else
        "anonymous:" + req.ip + ":" + req.get("User-Agent")
    return res.status(400).json { error: "Missing body parameter name or option" } unless name? and body?
    Poll.findOne req.body.name, (err, poll) ->
      return res.status(500).json err if err
      return if res.status(400).json { error: "Poll not found" } unless poll

      try
        poll.vote(option, user)
      catch e
        return res.status(400).json error: "Invalid option"
      
      poll.save ->
        res.json poll.options
    
