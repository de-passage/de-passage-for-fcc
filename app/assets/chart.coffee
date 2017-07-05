$ ->
  charts = $(".poll-results")
  charts.each ->
    chart = $ this
    ctx = chart.find(".poll-chart")[0]
    options = []
    votes = []
    colors = []
    borders = []
    chart.find(".option-result").each ->
      option = $ this
      options.push option.find(".option-name").html()
      votes.push parseInt(option.find(".vote-count").html(), 10)
      colors.push option.find(".vote-color").html()
      borders.push option.find(".vote-border").html()
      count = votes.reduce(((acc, x) -> acc += x), 0)
      console.log count
      if count
        option.hide()
        pieChart = new Chart ctx,
          type: 'pie'
          data:
            labels: options
            datasets: [
              label: "# of votes"
              data: votes
              backgroundColor: colors
              borderColor: borders

            ]
      else
        ctx.hide()



    

