module.exports =
  class Router
    @HTTPMethods = [ "get", "post", "patch", "put", "delete", "head", "options", "trace", "connect", "propfind", "proppatch", "mkcol", "copy", "move", "lock", "unlock", "versionControl", "report", "checkout", "checkin", "uncheckout", "mkworkspace", "update", "label", "merge", "baselineControl", "mkactivity", "orderpatch", "acl", "search" ]

    constructor: (@adapter, @app, @prefix) ->
      @adapter ?= (path, method) -> path
      @prefix ?= ""
      @routes = []

    # Create a new CRUD resource with the given `name`, associated with the `controller`
    resource: (name, controller, options) ->
      routes = [
        ["get", "new", "/#{name}/new"]
        ["post", "create", "/#{name}"]
        ["get", "show", "/#{name}/:#{name}_id"]
        ["get", "index", "/#{name}"]
        ["get", "edit", "/#{name}/:#{name}_id/edit"]
        ["put", "update", "/#{name}/:#{name}_id"]
        ["delete", "destroy", "/#{name}/:#{name}_id"]
      ]
      for route in routes
        if typeof controller[route[1]] is "function"
          @addRoute "#{route[1]}_#{name}", route[0], route[2], controller[route[1]]

    # Create a new route within the router and add it to the app if already provided
    addRoute: (alias, method, endpoint, middleware) ->
      adapter = Router.adapt @prefix + endpoint, method, @adapter
      if @app?
        @app.locals.path ?= {}
        @app.locals.path[alias] = adapter
        @app[method](@prefix + endpoint, middleware)
      else
        @routes.push [alias, method, endpoint, adapter, middleware]

    # Add all existing and later routes to the express app given in parameters
    use: (@app) ->
      @routes.each (args) ->
        @addRoute args...

    # Add every HTTP method to the prototype of router as an alias of addRoute
    for method in @HTTPMethods
      Router.prototype[method] = do (method) ->
        (alias, endpoint, middleware) ->
          @addRoute alias, method, endpoint, middleware

    # Return a sub router
    scope: (prefix) ->
      if prefix.charAt(0) != "/"
        prefix = "/" + prefix
      new Router(@adapter, @app, @prefix + prefix)


    # Transform a route into a function adapting parameters into a path
    @adapt = (endpoint, method, adapter) ->
      tokens = endpoint.split(/:[^/]+/)
      count = tokens.length - 1
      do (tokens, count) ->
        (args...) ->
          path = tokens[0]
          pos = 0
          while count--
            path += args[pos] + tokens[pos + 1]
            pos++
          path = adapter(path, method) if adapter?
          path
