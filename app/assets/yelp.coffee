getCoordinates = ->
  callLocAPI = ->
    new Promise (resolve, reject) ->
      $.ajax "http://ip-api.com/json",
        method: "GET"
        dataType: "json"
        success: resolve
        error: reject

  new Promise (resolve, reject) ->
    if navigator.geolocation?
      navigator.geolocation.getCurrentPosition ((pos) -> resolve(lon: pos.coords.longitude, lat: pos.coords.latitude)), reject
    else
      reject()
  .catch(callLocAPI)

searchVenues = (coords, text) ->
  new Promise (resolve, reject) ->
    if coords.lon? and coords.lat?
      url = window.searchURL + "&longitude=#{encodeURIComponent coords.lon}&latitude=#{encodeURIComponent coords.lat}"
      if text?
        url += "&term='#{encodeURIComponent text}'"
      $.ajax url,
        method: "GET"
        dataType: "json"
        success: resolve
        error: reject
    else
      reject()


ajaxTo = (url) ->
  new Promise( (resolve, reject) ->
    $.ajax url,
      method: "POST"
      success: resolve
      error: reject
  )

alertError = (data) =>
  alert "Error: #{data.responseJSON.error}"

harmonizeResult = (results) ->
  for result in results.businesses
    result.user_going ?= false
    result.shown = false
  return results.businesses

$ ->
  $("#venue-list").show()
  venueList = new Vue
    el: "#app-container"
    data:
      loading: true
      items: null
      coords: null
      update_url: window.updateUrl
      destroy_url: window.destroyUrl
    methods:
      toggle: (e) -> e.shown = !e.shown
      autocomplete: ->
        txt = $("#search-bar").val()
        if this.coords.lat? and this.coords.lon?
          $.ajax window.autocompleteURL + "?longitude=#{encodeURIComponent(this.coords.lon)}&latitude=#{encodeURIComponent(this.coords.lat)}&text='#{encodeURIComponent(txt)}'",
            method: "GET",
            dataType: "json"
          .done((args) ->
            console.log "response: ", JSON.stringify(args)
          ).fail -> console.log "failed"
            
      search: (event) ->
        event.preventDefault()
        text = $("#search-bar").val()
        venueList.loading = true
        venueList.items = null
        searchVenues(this.coords, text).then (results) ->
          venueList.items = harmonizeResult results
          venueList.loading = false

      toggleVisit: (item) ->
        url = if item.user_going then venueList.destroy_url else venueList.update_url
        url = url.replace /ID/, item.id
        ajaxTo(url).then (data) =>
          item.going = data.visits.length
          item.user_going = !item.user_going
          for i in venueList.items
            if i.id != item.id and i.user_going
              i.user_going = false
              i.going--
        .catch alertError
          

  if window.yelpData
    venueList.loading = false
    venueList.items = harmonizeResult window.yelpData

  getCoordinates().then (coords) ->
    venueList.coords = coords
    if !window.yelpData
      searchVenues(coords).then (results) ->
        venueList.items = harmonizeResult results
        venueList.loading = false
  window.vue = venueList



