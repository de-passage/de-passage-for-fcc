
$ ->
  socket = new WebSocket("ws://#{window.location.hostname}:#{window.location.port}#{window.wsPath}")
  socket.onmessage = (event) ->
    $("#display").append $("<p>", html: event.data)
    console.log event

  btn = $("#test-btn")
  $("#msg").keypress (e) ->
    if e.which == 13
      e.preventDefault()
      btn.click()

  btn.click (e) ->
    e.preventDefault()
    text = $("#msg").val()
    console.log text
    socket.send text
