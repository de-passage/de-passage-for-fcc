removeOption = (i) ->
  ->
    $("#option-wrapper-#{i}").remove()



$ ->
  optionInputDiv = $("#option-input")
  addOptionBtn = optionInputDiv.find("#add-option")
  listItems = optionInputDiv.find(".list-group-item")
  count = listItems.length - 1
  listItems.each (index) ->
    $(@).find("button").click removeOption(index)

  addOptionBtn.click ->
    $("#add-option-li").before $ "<li>",
      class: "list-group-item"
      id: "option-wrapper-#{count}"
      html: $ "<div>",
          class: "container"
          html: $ "<div>",
            class: "row"
            html: [
              $("<div>",
                class: "col-12 col-md-7"
                html: $("<input>",
                  class: "form-control"
                  type: "text"
                  placeholder: "Option"
                  required: true
                  name: "options['___option-#{count}']")
              )
              $("<div>",
                class: "col-12 col-md-5"
                html: $("<div>",
                  class: "row",
                  html: [
                    $("<div>",
                      class: "col-8 col-lg-3"
                      html: $("<label>",
                        for: "colors-#{count}"
                        class: "form-check-label"
                        html: "Color"
                      )
                    )
                    $("<div>",
                      class: "col-4 col-lg-2"
                      html: $("<input>",
                        id: "colors-#{count}"
                        type: "color"
                        name: "colors['___option-#{count}']"
                        value: "#CCCCCC"
                        class: "form-check-input"
                      )
                    )
                    $("<div>",
                      class: "col-8 col-lg-3"
                      html: $("<label>",
                        for: "borders-#{count}"
                        class: "form-check-label"
                        html: "Border"
                      )
                    )
                    $("<div>",
                      class: "col-4 col-lg-2"
                      html: $("<input>",
                        id: "borders-#{count}"
                        type: "color"
                        name: "borders['___option-#{count}']"
                        value: "#333333"
                        class: "form-check-input"
                      )
                    )
                    $("<div>",
                      class: "col-2"
                      html: $("<button>",
                        class: "btn btn-danger"
                        type: "button"
                        html: "&times;"
                        click: removeOption(count)
                      )
                    )
                  ]
                )
              )
            ]


      count++
