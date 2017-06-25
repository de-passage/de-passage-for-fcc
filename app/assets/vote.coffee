$ ->
  form = $("#vote-form")
  if form.length
    $("#vote-btn").click ->
      pollName = form.find("[name=name]").val()
      option = form.find("input[name=option]:checked").val()
      $.ajax "/voting-app/polls/vote",
        method: "POST"
        dataType: "json"
        data:
          name: pollName
          option: option
        success: (data) -> console.log JSON.stringify data
        error: (data) -> console.log JSON.stringify data

  $("#add-option-btn").click ->
