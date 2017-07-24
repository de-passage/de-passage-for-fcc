module.exports =
  webSocket: (ws, req) ->
    ws.on "message", (msg) ->
      console.log msg
    console.log "accessed"

  show: (req, res) ->
    res.render("market/show.pug")
