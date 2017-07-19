$ ->
  data = []
  if window.yelpData
    for d in window.yelpData.businesses
      d.shown = false
    data = window.yelpData.businesses

  venueList = new Vue
    el: "#venue-list"
    data:
      items: data
    methods:
      toggle: (e) ->
        e.shown = !e.shown

