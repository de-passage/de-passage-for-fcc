$ ->
  form = $("#vote-form")
  $("#vote-btn").click (event) ->
    event.preventDefault()
    pollName = form.find("[name=name]").val()
    option = form.find("input[name=option]:checked").val()
    $.ajax "/voting-app/polls/vote",
      method: "POST"
      dataType: "json"
      data:
        name: pollName
        option: option
      success: (data) ->
        votes = new google.visualization.DataTable()
        votes.addColumn("string", "Option")
        votes.addColumn("number", "Vote")
        colors = []

        for name, values of data
          votes.addRow [name, values.count]
          colors.push values.color

        form.hide()
        $("#vote-display").show()
        window.drawChart(votes, $(".poll-results"), colors)

      error: (data) -> console.log JSON.stringify data

  $("#add-option-btn").click ->

  $("#show-form-btn").click ->
    $("#vote-form").show()
    $("#vote-display").hide()
