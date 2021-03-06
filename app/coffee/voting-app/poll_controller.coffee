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

serializeUser = (req) ->
  if req.user
    req.user.name
  else
    "anonymous:" + req.ip + ":" + req.get("User-Agent")


module.exports = (Poll) ->

  show: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/polls", req, res
      return if redirectUnlessFound poll, req.params.name, req, res
      u = serializeUser(req)
      hv = poll.hasVoted(u)
      res.render "polls/show.pug", poll: poll, hasVoted: hv, url: req.protocol + "://" + req.get("host") + req.originalUrl

  create: (req, res) ->
    { name, description, options, colors, borders } = req.body
    colors ?= {}
    borders ?= {}
    if options?
      options = (description: value, color: colors[key] || "#CCCCCC", border: borders[key] || "#444444" for key, value of options)
    poll = new Poll(req.user.name, name, description, options)
    poll.save (err, poll) ->
      return if redirectOnDBError err, "/voting-app/polls/new", req, res

      res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}"

  new: (req, res) ->
    res.render "polls/new.pug"

  edit: (req, res) ->
    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent poll.name}", req, res
      return if redirectUnlessFound poll, req.params.name, req, res

      res.render "polls/edit.pug", poll: poll

  index: (req, res) ->
    Poll.all (err, polls) ->
      return if redirectOnDBError err, "/", req, res
      res.render "polls/index.pug", polls: polls

  update: (req, res) ->
    { name, description, options, colors, borders, votes } = req.body
    colors ?= {}
    borders ?= {}
    votes ?= {}

    Poll.findOne name: req.params.name, (err, poll) ->
      return if redirectOnDBError err, "/voting-app/poll/#{encodeURIComponent req.params.name}", req, res

      if(name? or description?)
        if(req.user.name == poll.user)
          poll.name = name if name?
          poll.description = description if description?
          if options?
            newOptions = {}
            for key, value of options
              newOptions[key] =
                description: value
                count: votes[key] || 0
                color: colors[key] || "#CCCCCC"
                border: borders[key] || "#444444"
            poll.replaceOptions newOptions, req.user.name
          else
            poll.options = {}
            poll.voters = {}
        else
          req.flash("error", "You are not authorized to perform this action")
          return res.redirect "/voting-app/poll/#{encodeURIComponent poll.name}"
      else if options?
        if Array.isArray options
          for option in options
            poll.addOption option, req.user.name
        else
          poll.addOption options, req.user.name

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
    user = serializeUser(req)
    return res.status(400).json { error: "Missing body parameter name or option" } unless name? and option?

    Poll.findOne { name: name }, (err, poll) ->
      return res.status(500).json err if err
      return if res.status(400).json { error: "Poll not found" } unless poll

      try
        poll.vote(option, user)
      catch e
        return res.status(400).json error: "Invalid option. #{e}"
      
      poll.save (err, poll)->
        if err
          return res.status(400).json err
        res.json poll.options
    
