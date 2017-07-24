WebSocket = require "ws"

module.exports = (wss) ->
  webSocket: (ws, req) ->
    ws.on "message", (msg) ->
      console.log "Received:", msg
      wss.clients.forEach (client) ->
        if(client.readyState == WebSocket.OPEN)
          client.send(msg)

  show: (req, res) ->
    res.render("market/show.pug")
