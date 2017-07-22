// Generated by CoffeeScript 1.9.3
(function() {
  var cache, fetchYelpData, https;

  cache = require("memory-cache");

  https = require("https");

  fetchYelpData = function(req, res) {};

  module.exports = function(User) {
    return {
      show: function(req, res) {
        var id, path, token, url, view;
        id = req.params.venues_id;
        view = "venues/show.pug";
        url = "api.yelp.com";
        path = "/v3/businesses/" + id;
        token = cache.get("yelp_token");
        return https.get({
          host: url,
          path: path,
          headers: {
            "Authorization": "Bearer " + token
          },
          port: process.env.PORT
        }, function(resp) {
          var rawData;
          rawData = "";
          resp.on("data", function(chunk) {
            return rawData += chunk;
          });
          resp.on("end", function() {
            var e, parsedData;
            try {
              parsedData = JSON.parse(rawData);
              return User.aggregateVisits([id]).then(function(arr) {
                parsedData.visits = arr;
                return res.render(view, {
                  yelpData: parsedData
                });
              });
            } catch (_error) {
              e = _error;
              if (Array.isArray(app.locals.flash["error"])) {
                app.locals.flash["error"].push(e.message);
              } else {
                app.locals.flash["error"] = e.message;
              }
              return res.render(view);
            }
          });
          return resp.on("error", function(err) {
            if (Array.isArray(app.locals.flash["error"])) {
              app.locals.flash["error"].push(e.message);
            } else {
              app.locals.flash["error"] = e.message;
            }
            return res.render(view);
          });
        });
      },
      index: function(req, res) {
        var i, latitude, len, location, longitude, param, params, path, ref, ref1, token, type, url, view;
        ref = req.query, type = ref.type, longitude = ref.longitude, latitude = ref.latitude, location = ref.location;
        view = "venues/index.pug";
        if (((longitude != null) && (latitude != null)) || (location != null)) {
          params = [];
          ref1 = ["longitude", "latitude", "location", "term"];
          for (i = 0, len = ref1.length; i < len; i++) {
            param = ref1[i];
            if (req.query[param] != null) {
              params.push(param + "=" + encodeURIComponent(req.query[param]));
            }
          }
          url = "api.yelp.com";
          path = "/v3/businesses/search?" + params.join("&");
          token = cache.get("yelp_token");
          return https.get({
            host: url,
            path: path,
            headers: {
              "Authorization": "Bearer " + token
            },
            port: process.env.PORT
          }, function(resp) {
            var rawData;
            rawData = "";
            resp.on("data", function(chunk) {
              return rawData += chunk;
            });
            resp.on("end", function() {
              var business, e, parsedData, venues;
              try {
                parsedData = JSON.parse(rawData);
                venues = (function() {
                  var j, len1, ref2, results1;
                  ref2 = parsedData.businesses;
                  results1 = [];
                  for (j = 0, len1 = ref2.length; j < len1; j++) {
                    business = ref2[j];
                    results1.push(business.id);
                  }
                  return results1;
                })();
                return User.aggregateVisits(venues).then(function(results) {
                  var j, len1, ref2;
                  ref2 = parsedData.businesses;
                  for (j = 0, len1 = ref2.length; j < len1; j++) {
                    business = ref2[j];
                    business.going = results[business.id].length;
                  }
                  if (type === "json") {
                    return res.json(parsedData);
                  } else {
                    return res.render(view, {
                      yelpData: parsedData
                    });
                  }
                });
              } catch (_error) {
                e = _error;
                if (type === "json") {
                  return res.status(500).json(e);
                } else {
                  if (Array.isArray(app.locals.flash["error"])) {
                    app.locals.flash["error"].push(e.message);
                  } else {
                    app.locals.flash["error"] = e.message;
                  }
                  return res.render(view);
                }
              }
            });
            return resp.on("error", function(err) {
              if (type === "json") {
                return res.status(500).json(err);
              } else {
                if (Array.isArray(app.locals.flash["error"])) {
                  app.locals.flash["error"].push(e.message);
                } else {
                  app.locals.flash["error"] = e.message;
                }
                return res.render(view);
              }
            });
          });
        } else {
          if ("json" === type) {
            return res.json({});
          } else {
            return res.render(view);
          }
        }
      },
      search: function(req, res) {
        var i, len, param, params, path, ref, token, url;
        console.log("called");
        params = [];
        ref = ["longitude", "latitude", "text"];
        for (i = 0, len = ref.length; i < len; i++) {
          param = ref[i];
          if (req.query[param] != null) {
            params.push(param + "=" + encodeURIComponent(req.query[param]));
          }
        }
        url = "api.yelp.com";
        path = "/v3/autocomplete?" + params.join("&");
        token = cache.get("yelp_token");
        return https.get({
          host: url,
          path: path,
          headers: {
            "Authorization": "Bearer " + token
          },
          port: process.env.PORT
        }, function(resp) {
          var rawData;
          rawData = "";
          resp.on("data", function(chunk) {
            return rawData += chunk;
          });
          return resp.on("end", function() {
            var parsedData;
            try {
              parsedData = JSON.parse(rawData);
              return res.json(parsedData);
            } catch (_error) {}
          });
        });
      }
    };
  };

}).call(this);
