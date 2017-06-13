// Generated by CoffeeScript 1.9.3
(function() {
  var instanciatePoll;

  instanciatePoll = function(db) {
    var Poll;
    return Poll = (function() {
      function Poll(user1, name, description, options) {
        var i, len, option;
        this.user = user1;
        this.name = name;
        this.description = description;
        if (this.user == null) {
          throw "Not owner specified";
        }
        if (this.name == null) {
          throw "Not name specified";
        }
        if (this.description == null) {
          this.description = "";
        }
        this.options = [];
        if (Array.isArray(options)) {
          for (i = 0, len = options.length; i < len; i++) {
            option = options[i];
            this.addOption(option, this.user);
          }
        } else if (options != null) {
          this.addOption(options, this.user);
        }
      }

      Poll.prototype.save = function() {
        return db.save(this.id, {
          owner: this.user,
          name: this.name,
          description: this.description,
          options: this.options
        }, (function(_this) {
          return function(err, id) {
            return _this.id = id;
          };
        })(this));
      };

      Poll.prototype.addOption = function(option, user) {
        var o;
        if (option.description == null) {
          throw "An option must be a JSON object containing the field `description`";
        }
        option.user = user;
        if (option.count == null) {
          option.count = 0;
        }
        option.description = option.description.trim();
        if (((function() {
          var i, len, ref, results;
          ref = this.options;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            o = ref[i];
            if (o.description === option.description) {
              results.push(o);
            }
          }
          return results;
        }).call(this)).length !== 0) {
          throw "An option with the same name already exists";
        }
        return this.options.push(option);
      };

      Poll.prototype.removeOption = function(option) {
        return this.options = this.options.filter(function(e) {
          return e.description !== option;
        });
      };

      Poll.prototype["delete"] = function() {
        if (this.id == null) {
          throw "This poll is not registered in the database";
        }
        return db["delete"](this.id);
      };

      return Poll;

    })();
  };

  module.exports = instanciatePoll;

}).call(this);
