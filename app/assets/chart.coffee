@drawChart = (data, container, colors) ->
  chart = new google.visualization.PieChart(container.find(".chart-div").get(0))
  width = container.width()
  console.log width
  chart.draw data,
    height: container.width()
    width: container.width()
    sliceVisibilityThreshold: 0
    colors: colors
    legend: if !window.hideChartLegend then {} else 'none'

showChart = (data) ->
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
    window.drawChart data, poll_result, colors


$ ->
  google.charts.load("current", packages: ['corechart'])
  google.charts.setOnLoadCallback showChart
