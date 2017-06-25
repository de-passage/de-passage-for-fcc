$ ->
  form = $("#vote-form")
  console.log JSON.stringify form
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

  $("#add-option-btn").click ->
