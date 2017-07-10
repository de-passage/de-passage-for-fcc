module.exports =
  class Router
    constructor: (@app, @prefix) ->
      @prefix ?= ""
      @routes = []

    resources: (name, controller, options) ->
      routes = [
        ["get", "new", "/#{name}/new", -> "/#{name}/new"]
        ["post", "create", "/#{name}", -> "/#{name}"]
        ["get", "show", "/#{name}/:id", (id) -> "/#{name}/#{id}"]
        ["get", "index", "/#{name}", -> "/#{name}"]
        ["get", "edit", "/#{name}/:id/edit", (id) -> "/#{name}/#{id}/edit"]
        ["put", "update", "/#{name}/:id", (id) -> "/#{name}/#{id}?_method=PUT"]
        ["delete", "destroy", "/#{name}/:id", (id) -> "/#{name}/#{id}?_method=DELETE"]
      ]
      for route in routes
        if typeof controller[route[1]] is "function"
          @addRoute "#{route[1]}_#{name}", route[0], route[2], routes[3], controller[route[1]]

    addRoute: (alias, method, endpoint, adapter, middleware) ->
      if @app?
        @app.locals.path ?= {}
        @app.locals.path[alias] = adapter
        @app[method](@prefix + endpoint, middleware)
      else
        @routes.push [alias, method, endpoint, adapter, middleware]

    use: (@app) ->
      @routes.each (args) ->
        @addRoute args...

    for method in [ "get", "post", "patch", "put", "delete", "head", "options", "trace", "connect", "propfind", "proppatch", "mkcol", "copy", "move", "lock", "unlock", "versionControl", "report", "checkout", "checkin", "uncheckout", "mkworkspace", "update", "label", "merge", "baselineControl", "mkactivity", "orderpatch", "acl", "search" ]
      Router.prototype[method] = (alias, endpoint, middleware) ->
        @addRoute alias, method, endpoint, Router.adapt(endpoint + if method not in ["get", "post"] then "?_method=#{method.toUpperCase()}" else ""), middleware

    scope: (prefix) ->
      if prefix.charAt(0) != "/"
        prefix = "/" + prefix
      new Router(@app, @prefix + prefix)


    @adapt = (endpoint) ->
      tokens = endpoint.split(/:[^/]+/)
      count = tokens.length - 1
      do (tokens, count) ->
        (args...) ->
          path = tokens[0]
          pos = 0
          while count--
            path += args[pos] + tokens[pos + 1]
            pos++
          path
          



