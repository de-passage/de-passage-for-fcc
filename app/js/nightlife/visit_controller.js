// Generated by CoffeeScript 1.9.3
(function() {
  module.exports = function(User) {
    return {
      index: function(req, res) {
        return User.aggregateVisits;
      },
      create: function(req, res) {},
      show: function(req, res) {
        return res.send(JSON.stringify(req.params));
      }
    };
  };

}).call(this);
