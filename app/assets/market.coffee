

$ ->
  socket = new WebSocket("ws://#{window.location.hostname}:#{window.location.port}#{window.wsPath}")
  socket.onmessage = (event) ->
    console.log event
