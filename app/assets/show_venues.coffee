$ ->
  button = $ "#visit"
  button.click ->
    self = $ this
    url = self.attr("data-path")
    going = self.attr("data-going")
    going = !JSON.parse going
    $.ajax url,
      method: "POST"
      success: (data) ->
        self.attr("data-path", data.url)
        if going
          self.html("Cancel my visit")
        else
          self.html("I am going")
        self.toggleClass("btn-primary btn-success")
        self.attr("data-going", going ? "true" : "false")

  vue = new Vue
    el: "#visit"
    data:
      visits: window.visits
      user_going: window.user_going
      update_url: window.update_url
      destroy_url: window.destroy_url
    methods:
      {}
