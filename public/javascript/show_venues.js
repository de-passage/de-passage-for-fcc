// Generated by CoffeeScript 1.9.3
(function() {
  $(function() {
    var button, vue;
    button = $("#visit");
    button.click(function() {
      var going, self, url;
      self = $(this);
      url = self.attr("data-path");
      going = self.attr("data-going");
      going = !JSON.parse(going);
      return $.ajax(url, {
        method: "POST",
        success: function(data) {
          self.attr("data-path", data.url);
          if (going) {
            self.html("Cancel my visit");
          } else {
            self.html("I am going");
          }
          self.toggleClass("btn-primary btn-success");
          return self.attr("data-going", going != null ? going : {
            "true": "false"
          });
        }
      });
    });
    return vue = new Vue({
      el: "#visit",
      data: {
        visits: window.visits,
        user_going: window.user_going,
        update_url: window.update_url,
        destroy_url: window.destroy_url
      },
      methods: {}
    });
  });

}).call(this);
