// Generated by CoffeeScript 1.9.3
(function() {
  $(function() {
    var socket;
    socket = new WebSocket("ws://" + window.location.hostname + ":" + window.location.port + window.wsPath);
    return socket.onmessage = function(event) {
      return console.log(event);
    };
  });

}).call(this);
