// Generated by CoffeeScript 1.9.3
(function() {
  var Router,
    slice = [].slice;

  module.exports = Router = (function() {
    var i, len, method, ref;

    Router.HTTPMethods = ["get", "post", "patch", "put", "delete", "head", "options", "trace", "connect", "propfind", "proppatch", "mkcol", "copy", "move", "lock", "unlock", "versionControl", "report", "checkout", "checkin", "uncheckout", "mkworkspace", "update", "label", "merge", "baselineControl", "mkactivity", "orderpatch", "acl", "search"];

    function Router(adapter1, app, prefix1) {
      this.adapter = adapter1;
      this.app = app;
      this.prefix = prefix1;
      if (this.adapter == null) {
        this.adapter = function(path, method) {
          return path;
        };
      }
      if (this.prefix == null) {
        this.prefix = "";
      }
      this.routes = [];
    }

    Router.prototype.resource = function(name, controller, options) {
      var i, len, results, route, routes;
      routes = [["get", "new", "/" + name + "/new"], ["post", "create", "/" + name], ["get", "show", "/" + name + "/:" + name + "_id"], ["get", "index", "/" + name], ["get", "edit", "/" + name + "/:" + name + "_id/edit"], ["put", "update", "/" + name + "/:" + name + "_id"], ["delete", "destroy", "/" + name + "/:" + name + "_id"]];
      results = [];
      for (i = 0, len = routes.length; i < len; i++) {
        route = routes[i];
        if (typeof controller[route[1]] === "function") {
          results.push(this.addRoute(route[1] + "_" + name, route[0], route[2], controller[route[1]]));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    Router.prototype.addRoute = function(alias, method, endpoint, middleware) {
      var adapter, base;
      adapter = Router.adapt(this.prefix + endpoint, method, this.adapter);
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

    ref = Router.HTTPMethods;
    for (i = 0, len = ref.length; i < len; i++) {
      method = ref[i];
      Router.prototype[method] = (function(method) {
        return function(alias, endpoint, middleware) {
          return this.addRoute(alias, method, endpoint, middleware);
        };
      })(method);
    }

    Router.prototype.scope = function(prefix) {
      if (prefix.charAt(0) !== "/") {
        prefix = "/" + prefix;
      }
      return new Router(this.adapter, this.app, this.prefix + prefix);
    };

    Router.adapt = function(endpoint, method, adapter) {
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
          if (adapter != null) {
            path = adapter(path, method);
          }
          return path;
        };
      })(tokens, count);
    };

    return Router;

  })();

}).call(this);
