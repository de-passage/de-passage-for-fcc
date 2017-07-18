displayVenues = (data) ->
  venues = data.businesses
  div = $("#venues")
  div.empty()
  for venue in venues
    div.append $ "<div>", html: JSON.stringify venue



$ ->
  if window.yelpData
    displayVenues window.yelpData
