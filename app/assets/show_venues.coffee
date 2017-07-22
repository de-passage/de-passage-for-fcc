ajaxTo = (url) ->
  new Promise( (resolve, reject) ->
    $.ajax url,
      method: "POST"
      success: resolve
      error: reject
  )

alertError = (data) =>
  alert "Error: #{data.responseJSON.error}"

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

  window.vue = new Vue
    el: "#visit-display"
    data:
      visits: window.yelpVisits
      yelpId: window.yelpId
      user_going: window.user_going
      update_url: window.update_url
      destroy_url: window.destroy_url
      user_logged_in: window.user_logged_in
    methods:
      toggleVisit: ->
        console.log @user_going
        if @user_going
          ajaxTo(destroy_url).then (data) =>
            vue.visits = data.visits
            vue.user_going = false
          .catch alertError
        else
          ajaxTo(update_url).then (data) =>
            vue.visits = data.visits
            vue.user_going = true
          .catch alertError
