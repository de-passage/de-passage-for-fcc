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
