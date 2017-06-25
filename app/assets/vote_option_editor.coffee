removeOption = (i) ->
  ->
    $("#option-wrapper-#{i}").remove()



$ ->
  optionInputDiv = $("#option-input")
  addOptionBtn = optionInputDiv.find("#add-option")
  listItems = optionInputDiv.find(".list-group-item")
  count = listItems.length
  listItems.each (index) ->
    $(@).find("button").click removeOption(index)

  addOptionBtn.click ->
    $("#add-option-li").before $ "<li>",
      class: "list-group-item"
      id: "option-wrapper-#{count}"
      html: [
        $("<input>",
          class: "form-control"
          type: "text"
          placeholder: "Option"
          required: true
          name: "options['___option-#{count}']")
        $("<button>",
          class: "btn btn-danger"
          type: "button"
          html: "&times;"
          click: removeOption(count)
        )
      ]
      count++
