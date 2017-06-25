// Generated by CoffeeScript 1.9.3
(function() {
  var instanciatePoll;

  instanciatePoll = function(db, ObjectId) {
    var Poll;
    return Poll = (function() {
      function Poll(user1, name1, description, options) {
        var i, len, option;
        this.user = user1;
        this.name = name1;
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
        this.options = {};
        this.voters = {};
        if (Array.isArray(options)) {
          for (i = 0, len = options.length; i < len; i++) {
            option = options[i];
            this.addOption(option, this.user);
          }
        } else if (options != null) {
          this.addOption(options, this.user);
        }
      }

      Poll.prototype.save = function(callback) {
        return db.save(this.serialize(), (function(_this) {
          return function(err, obj) {
            _this.id = obj._id;
            if (callback != null) {
              if (err) {
                return callback(err);
              }
              return callback(null, _this);
            }
          };
        })(this));
      };

      Poll.prototype.addOption = function(option, user) {
        var name, newOption;
        name = option.description.trim();
        if (this.options[name]) {
          throw "An option with the name '" + name + "' already exists";
        }
        newOption = {
          user: user,
          count: option.count || 0
        };
        return this.options[name] = newOption;
      };

      Poll.prototype.removeOption = function(option) {
        return delete this.options[option];
      };

      Poll.prototype.vote = function(option, username) {
        if (this.options[option] == null) {
          throw "Option '" + option + "' does not exist";
        }
        if (this.voter[username] != null) {
          this.options[this.voter[username]].count--;
        }
        this.options[option].count++;
        return this.voter[username] = option;
      };

      Poll.prototype.hasVoted = function(username) {
        return this.voter[username] != null;
      };

      Poll.prototype.optionCount = function() {
        return Object.keys(this.options).length;
      };

      Poll.prototype.replaceOptions = function(newOptions, user) {
        var key, oldOptions, results, value;
        oldOptions = this.options;
        this.options = {};
        results = [];
        for (key in newOptions) {
          value = newOptions[key];
          if (oldOptions[key] != null) {
            results.push(this.options[value] = oldOptions[key]);
          } else {
            results.push(this.addOption({
              description: value
            }, user));
          }
        }
        return results;
      };

      Poll.prototype["delete"] = function() {
        if (this.id == null) {
          throw "This poll is not registered in the database";
        }
        return db.remove({
          _id: ObjectId(this.id)
        });
      };

      Poll.deserialize = function(obj) {
        var poll;
        poll = new Poll(obj.owner, obj.name, obj.description);
        if (obj._id != null) {
          poll.id = obj._id;
        }
        if (obj.options != null) {
          poll.options = obj.options;
        }
        if (obj.voters != null) {
          poll.voters = obj.voters;
        }
        poll.created_at = obj.created_at;
        return poll;
      };

      Poll.prototype.serialize = function() {
        var obj;
        obj = {
          owner: this.user,
          name: this.name,
          description: this.description,
          options: this.options,
          voters: this.voters,
          created_at: this.created_at || (new Date).getTime()
        };
        if (this.id != null) {
          obj._id = ObjectId(this.id);
        }
        return obj;
      };

      Poll.findOne = function(search, callback) {
        return db.findOne(search, (function(_this) {
          return function(err, poll) {
            var result;
            if (err) {
              callback(err);
            }
            result = false;
            if (poll) {
              result = _this.deserialize(poll);
            }
            return callback(null, result);
          };
        })(this));
      };

      Poll.all = function(limit, callback) {
        var cursor;
        cursor = db.find({});
        if (typeof limit === "function") {
          callback = limit;
        } else {
          cursor = cursor.limit(limit);
        }
        return cursor.toArray((function(_this) {
          return function(err, arr) {
            if (err) {
              return callback(err);
            }
            arr || (arr = []);
            return callback(null, arr.map(_this.deserialize));
          };
        })(this));
      };

      return Poll;

    })();
  };

  module.exports = instanciatePoll;

}).call(this);
