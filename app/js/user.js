// Generated by CoffeeScript 1.9.3
(function() {
  var ObjectId, bcrypt, instanciateUser;

  bcrypt = require("bcrypt-nodejs");

  ObjectId = require("mongodb").ObjectId;

  instanciateUser = function(db) {
    var User;
    return User = (function() {
      function User(name, email, password1, visit) {
        this.name = name;
        this.email = email;
        this.password = password1;
        this.visit = visit;
        if (this.visit == null) {
          this.visit = {};
        }
      }

      User.prototype.verifyPassword = function(password) {
        return bcrypt.compareSync(password, this.password);
      };

      User.prototype.setPassword = function(password) {
        return this.password = bcrypt.hashSync(password, bcrypt.genSaltSync(8), null);
      };

      User.prototype.save = function(callback) {
        return db.save({
          _id: this.id ? ObjectId(this.id) : void 0,
          username: this.name,
          email: this.email,
          password: this.password,
          visit: this.visit
        }, (function(_this) {
          return function(err, obj) {
            if (err) {
              return typeof callback === "function" ? callback(err) : void 0;
            }
            _this.id = obj._id;
            return typeof callback === "function" ? callback(null, _this) : void 0;
          };
        })(this));
      };

      User.findOne = function(params, callback) {
        return db.findOne(params, function(err, result) {
          var user;
          if (err) {
            callback(err);
          }
          user = false;
          if (result != null) {
            user = new User(result.username, result.email, result.password, result.visit);
            user.id = result._id;
          }
          return callback(null, user);
        });
      };

      User.aggregateVisits = function(venues) {
        return new Promise(function(resolve, reject) {
          return db.find({
            visit: {
              $in: venues
            }
          }, {
            visit: 1,
            username: 1
          }).toArray(function(err, arr) {
            var e, i, j, len, len1, res, venue;
            if (err) {
              return reject(err);
            }
            if (!arr) {
              return resolve([]);
            }
            console.log(arr);
            res = {};
            for (i = 0, len = venues.length; i < len; i++) {
              venue = venues[i];
              res[venue] = [];
            }
            for (j = 0, len1 = arr.length; j < len1; j++) {
              e = arr[j];
              res[e.visit].push(e.username);
            }
            return resolve(res);
          });
        });
      };

      return User;

    })();
  };

  module.exports = instanciateUser;

}).call(this);
