removeOption = (i) ->
  ->
    $("#option-wrapper-#{i}").remove()



$ ->
  optionInputDiv = $("#option-input")
  addOptionBtn = optionInputDiv.find("#add-option")
  count = optionInputDiv.find(".list-group-item").length
  addOptionBtn.click ->
    $("#add-option-li").before $ "<li>",
      class: "list-group-item"
      id: "option-wrapper-#{count}"
      html: [
        $("<input>",
          type: "text"
          placeholder: "Option"
          required: true
          name: "options[#{count}]")
        $("<button>",
          type: "button"
          html: "&times;"
          click: removeOption(count)
        )
      ]
      count++
