module.exports = (Poll) ->
  create: (req, res) ->
    poll = req.params.name
    name = req.body.option
    color = req.body.color
    Poll.findOne name: poll, (err, poll) ->
      if err
        req.flash "error", "Database error..."
        return res.redirect "/voting-app"
      unless poll
        req.flash "error", "The poll `#{poll.name}` doesn't exist"
        return res.redirect "/voting-app"
      unless name
        req.flash "error", "Options need to be named"
        return res.redirect "/voting-app/poll/#{poll.name}"
      try
       poll.addOption { description: name, color: color }, req.user
       poll.save ->
        return res.redirect "/voting-app/poll/#{poll.name}"

      catch e
        req.flash "error", e.message
        return res.redirect "/voting-app/poll/#{poll.name}"
    
