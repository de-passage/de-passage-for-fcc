// Generated by CoffeeScript 1.9.3
(function() {
  var Router,
    slice = [].slice;

  module.exports = Router = (function() {
    var i, len, method, ref;

    function Router(app, prefix1) {
      this.app = app;
      this.prefix = prefix1;
      if (this.prefix == null) {
        this.prefix = "";
      }
      this.routes = [];
    }

    Router.prototype.resources = function(name, controller, options) {
      var i, len, results, route, routes;
      routes = [
        [
          "get", "new", "/" + name + "/new", function() {
            return "/" + name + "/new";
          }
        ], [
          "post", "create", "/" + name, function() {
            return "/" + name;
          }
        ], [
          "get", "show", "/" + name + "/:id", function(id) {
            return "/" + name + "/" + id;
          }
        ], [
          "get", "index", "/" + name, function() {
            return "/" + name;
          }
        ], [
          "get", "edit", "/" + name + "/:id/edit", function(id) {
            return "/" + name + "/" + id + "/edit";
          }
        ], [
          "put", "update", "/" + name + "/:id", function(id) {
            return "/" + name + "/" + id + "?_method=PUT";
          }
        ], [
          "delete", "destroy", "/" + name + "/:id", function(id) {
            return "/" + name + "/" + id + "?_method=DELETE";
          }
        ]
      ];
      results = [];
      for (i = 0, len = routes.length; i < len; i++) {
        route = routes[i];
        if (typeof controller[route[1]] === "function") {
          results.push(this.addRoute(route[1] + "_" + name, route[0], route[2], routes[3], controller[route[1]]));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    Router.prototype.addRoute = function(alias, method, endpoint, adapter, middleware) {
      var base;
      if (this.app != null) {
        if ((base = this.app.locals).path == null) {
          base.path = {};
        }
        this.app.locals.path[alias] = adapter;
        return this.app[method](this.prefix + endpoint, middleware);
      } else {
        return this.routes.push([alias, method, endpoint, adapter, middleware]);
      }
    };

    Router.prototype.use = function(app) {
      this.app = app;
      return this.routes.each(function(args) {
        return this.addRoute.apply(this, args);
      });
    };

    ref = ["get", "post", "patch", "put", "delete", "head", "options", "trace", "connect", "propfind", "proppatch", "mkcol", "copy", "move", "lock", "unlock", "versionControl", "report", "checkout", "checkin", "uncheckout", "mkworkspace", "update", "label", "merge", "baselineControl", "mkactivity", "orderpatch", "acl", "search"];
    for (i = 0, len = ref.length; i < len; i++) {
      method = ref[i];
      Router.prototype[method] = function(alias, endpoint, middleware) {
        return this.addRoute(alias, method, endpoint, Router.adapt(endpoint + (method !== "get" && method !== "post" ? "?_method=" + (method.toUpperCase()) : "")), middleware);
      };
    }

    Router.prototype.scope = function(prefix) {
      if (prefix.charAt(0) !== "/") {
        prefix = "/" + prefix;
      }
      return new Router(this.app, this.prefix + prefix);
    };

    Router.adapt = function(endpoint) {
      var count, tokens;
      tokens = endpoint.split(/:[^\/]+/);
      count = tokens.length - 1;
      return (function(tokens, count) {
        return function() {
          var args, path, pos;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          path = tokens[0];
          pos = 0;
          while (count--) {
            path += args[pos] + tokens[pos + 1];
            pos++;
          }
          return path;
        };
      })(tokens, count);
    };

    return Router;

  })();

}).call(this);