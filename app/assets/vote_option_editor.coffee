removeOption = (i) ->
  ->
    $("#option-wrapper-#{i}").remove()

previewChart = ->
  colors = []
  data = new google.visualization.DataTable()
  data.addColumn("string", "Option")
  data.addColumn("number", "Votes")
  $(".option-edition").each ->
    self = $(this)
    name = self.find(".option-name").val()
    color = self.find(".option-color").val()
    colors.push color
    data.addRow [name, 1]

  chart = new google.visualization.PieChart($(".chart-div").get(0))
  chart.draw data, colors: colors, height: $(".chart-div").width()




$ ->
  # Load Google Charts
  google.charts.load("current", packages: ['corechart'])
  google.charts.setOnLoadCallback previewChart

  # Get the desired elements from the dom
  optionInputDiv = $("#option-input")
  addOptionBtn = optionInputDiv.find("#add-option")
  listItems = optionInputDiv.find(".list-group-item")
  count = listItems.length

  # Attach the delete function to the existing buttons
  listItems.each (index) ->
    $(@).find("button").click removeOption(index)

  defaultColors = [
    "#ffff00"
    "#ff0000"
    "#00ff00"
    "#0000ff"
    "#ff00ff"
    "#00ffff"
  ]

  # Callback for the option creation button
  addOptionBtn.click ->
    $("#add-option-li").before $ "<li>",
      class: "list-group-item option-edition"
      id: "option-wrapper-#{count}"
      html: $ "<div>",
          class: "container"
          html: $ "<div>",
            class: "row"
            html: [
              $("<div>",
                class: "col-12 col-md-7"
                html: $("<input>",
                  class: "form-control option-name"
                  type: "text"
                  placeholder: "Option"
                  required: true
                  on:
                    input: previewChart
                  name: "options['___option-#{count}']")
              )
              $("<div>",
                class: "col-12 col-md-5"
                html: $("<div>",
                  class: "row",
                  html: [
                    $("<div>",
                      class: "col-8 col-lg-5"
                      html: $("<label>",
                        for: "colors-#{count}"
                        class: "form-check-label"
                        html: "Color"
                      )
                    )
                    $("<div>",
                      class: "col-4 col-lg-3"
                      html: $("<input>",
                        id: "colors-#{count}"
                        type: "color"
                        name: "colors['___option-#{count}']"
                        value: defaultColors[count % defaultColors.length]
                        class: "form-check-input option-color"
                        on:
                          input: previewChart
                      )
                    )
                    $("<div>",
                      class: "col-4"
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
      previewChart()
