drawChart = ->
  $(".poll-results").each ->
    data =  new google.visualization.DataTable()
    data.addColumn("string", "Option")
    data.addColumn("number", "Votes")

    colors = []
    poll_result = $(this)
    poll_result.find(".option-result").each ->
      option = $(this)
      colors.push option.find(".vote-color").html()
      name = option.find(".option-name").html()
      vote = parseInt(option.find(".vote-count").html(), 10)
      data.addRow [name, vote]
      option.hide()

    chart = new google.visualization.PieChart(poll_result.find(".chart-div").get(0))
    chart.draw data, height: Math.min(poll_result.width(), 500)

$ ->
  google.charts.load("current", packages: ['corechart'])
  google.charts.setOnLoadCallback drawChart
