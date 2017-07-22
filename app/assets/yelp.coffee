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




$ ->
  $("#venue-list").show()
  venueList = new Vue
    el: "#app-container"
    data:
      items: []
      coords: null
    methods:
      toggle: (e) -> e.shown = !e.shown
      autocomplete: ->
        txt = $("#search-bar").val()
        if this.coords.lat? and this.coords.lon?
          $.ajax window.autocompleteURL + "?longitude=#{encodeURIComponent(this.coords.lon)}&latitude=#{encodeURIComponent(this.coords.lat)}&text='#{encodeURIComponent(txt)}'",
            method: "GET",
            dataType: "json"
          .done((args) ->
            #console.log "response: ", JSON.stringify(args)
          ).fail -> console.log "failed"
            
      search: (event) ->
        event.preventDefault()
        text = $("#search-bar").val()
        searchVenues(this.coords, text).then (results) ->
          for result in results.businesses
            result.shown = false
          venueList.items = results.businesses
          

  if window.yelpData
    for d in window.yelpData.businesses
      d.shown = false
    venueList.items = window.yelpData.businesses

  getCoordinates().then (coords) ->
    venueList.coords = coords
    if !window.yelpData
      searchVenues(coords).then (results) ->
        for result in results.businesses
          result.shown = false
        venueList.items = results.businesses




