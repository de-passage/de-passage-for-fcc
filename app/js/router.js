// Generated by CoffeeScript 1.9.3
(function() {
  var Router, _extract, extract, filter,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  _extract = function(data) {
    var d, i, len, results;
    if (Array.isArray(data)) {
      results = [];
      for (i = 0, len = data.length; i < len; i++) {
        d = data[i];
        results.push(_extract(d));
      }
      return results;
    } else if (typeof data === "function") {
      return {
        use: [data],
        except: []
      };
    } else if (data == null) {
      return [];
    } else {
      if (data.use != null) {
        if (!Array.isArray(data.use)) {
          data.use = [data.use];
        }
      } else {
        data.use = [];
      }
      if (!((data.only != null) || (data.except != null))) {
        data.except = [];
      }
      return data;
    }
  };

  extract = function(data) {
    var d;
    d = _extract(data);
    if (Array.isArray(d)) {
      return d;
    } else {
      return [d];
    }
  };

  filter = function(array, verb) {
    var data, i, len, r;
    r = [];
    for (i = 0, len = array.length; i < len; i++) {
      data = array[i];
      if ((data.only != null) && !Array.isArray(data.only)) {
        data.only = [data.only];
      }
      if ((data.except != null) && !Array.isArray(data.except)) {
        data.except = [data.except];
      }
      if (!(((data.only != null) && indexOf.call(data.only, verb) < 0) || ((data.except != null) && indexOf.call(data.except, verb) >= 0))) {
        r.push.apply(r, data.use);
      }
    }
    return r;
  };

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

    Router.prototype.resource = function(name, controller, options, callback) {
      var a, after, b, before, i, len, r, route, routes;
      if (typeof options === "function") {
        callback = options;
        options = null;
      }
      routes = [["get", "new", "/" + name + "/new"], ["post", "create", "/" + name], ["get", "show", "/" + name + "/:" + name + "_id"], ["get", "index", "/" + name], ["get", "edit", "/" + name + "/:" + name + "_id/edit"], ["put", "update", "/" + name + "/:" + name + "_id"], ["delete", "destroy", "/" + name + "/:" + name + "_id"]];
      before = extract(controller.before);
      after = extract(controller.after);
      for (i = 0, len = routes.length; i < len; i++) {
        route = routes[i];
        if (typeof controller[route[1]] === "function") {
          b = filter(before, route[1]);
          a = filter(after, route[1]);
          this.addRoute.apply(this, [route[1] + "_" + name, route[0], route[2]].concat(slice.call(b), [controller[route[1]]], slice.call(a)));
        }
      }
      r = new Router(this.adapter, this.app, this.prefix + ("/" + name + "/:" + name + "_id"));
      if (typeof callback === "function") {
        callback(r);
      }
      return r;
    };

    Router.prototype.addRoute = function() {
      var adapter, alias, base, endpoint, method, middlewares, ref;
      alias = arguments[0], method = arguments[1], endpoint = arguments[2], middlewares = 4 <= arguments.length ? slice.call(arguments, 3) : [];
      adapter = Router.adapt(this.prefix + endpoint, method, this.adapter);
      if (this.app != null) {
        if ((base = this.app.locals).path == null) {
          base.path = {};
        }
        this.app.locals.path[alias] = adapter;
        return (ref = this.app)[method].apply(ref, [this.prefix + endpoint].concat(slice.call(middlewares)));
      } else {
        return this.routes.push([alias, method, endpoint, adapter].concat(slice.call(middlewares)));
      }
    };

    Router.prototype.use = function(app) {
      this.app = app;
      return this.routes.forEach((function(_this) {
        return function(args) {
          return _this.addRoute.apply(_this, args);
        };
      })(this));
    };

    ref = Router.HTTPMethods;
    for (i = 0, len = ref.length; i < len; i++) {
      method = ref[i];
      Router.prototype[method] = (function(method) {
        return function() {
          var alias, endpoint, middlewares;
          alias = arguments[0], endpoint = arguments[1], middlewares = 3 <= arguments.length ? slice.call(arguments, 2) : [];
          return this.addRoute.apply(this, [alias, method, endpoint].concat(slice.call(middlewares)));
        };
      })(method);
    }

    Router.prototype.scope = function(prefix, callback) {
      var r;
      if (prefix.charAt(0) !== "/") {
        prefix = "/" + prefix;
      }
      r = new Router(this.adapter, this.app, this.prefix + prefix);
      if (typeof callback === "function") {
        callback(r);
      }
      return r;
    };

    Router.prototype.root = function() {
      var alias, middlewares;
      alias = arguments[0], middlewares = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      return this.addRoute.apply(this, [alias, "get", "/"].concat(slice.call(middlewares)));
    };

    Router.adapt = function(endpoint, method, adapter) {
      var count, tokens;
      tokens = endpoint.split(/:[^\/]+/);
      count = tokens.length - 1;
      if (count < 0) {
        count = 0;
      }
      return (function(tokens, count, adapter) {
        return function() {
          var args, j, path, pos, ref1;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          path = tokens[0];
          for (pos = j = 0, ref1 = count; 0 <= ref1 ? j < ref1 : j > ref1; pos = 0 <= ref1 ? ++j : --j) {
            path += args[pos] + tokens[pos + 1];
          }
          if (adapter != null) {
            path = adapter(path, method);
          }
          return path;
        };
      })(tokens, count, adapter);
    };

    return Router;

  })();

}).call(this);
