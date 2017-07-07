// Generated by CoffeeScript 1.9.3
(function() {
  $(function() {
    var form;
    form = $("#vote-form");
    if (form.length) {
      $("#vote-btn").click(function() {
        var option, pollName;
        pollName = form.find("[name=name]").val();
        option = form.find("input[name=option]:checked").val();
        return $.ajax("/voting-app/polls/vote", {
          method: "POST",
          dataType: "json",
          data: {
            name: pollName,
            option: option
          },
          success: function(data) {
            return console.log(JSON.stringify(data));
          },
          error: function(data) {
            return console.log(JSON.stringify(data));
          }
        });
      });
    }
    return $("#add-option-btn").click(function() {});
  });

}).call(this);