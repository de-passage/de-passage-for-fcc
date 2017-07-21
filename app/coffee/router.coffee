_extract = (data) ->
  if Array.isArray data
    (_extract d for d in data)
  else if typeof data is "function"
    { use: [data], except: [] }
  else unless data?
    []
  else
    if data.use?
      unless Array.isArray data.use
        data.use = [data.use]
    else
      data.use = []
    unless data.only? or data.except?
      data.except = []
    data

extract = (data) ->
  d = _extract data
  if Array.isArray d
    d
  else
    [d]

filter = (array, verb) ->
  r = []
  for data in array
    if data.only? and not Array.isArray data.only
      data.only = [data.only]
    if data.except? and not Array.isArray data.except
      data.except = [data.except]
    unless (data.only? and verb not in data.only) or (data.except? and verb in data.except)
      r.push data.use...
  r



module.exports =
  class Router
    @HTTPMethods = [ "get", "post", "patch", "put", "delete", "head", "options", "trace", "connect", "propfind", "proppatch", "mkcol", "copy", "move", "lock", "unlock", "versionControl", "report", "checkout", "checkin", "uncheckout", "mkworkspace", "update", "label", "merge", "baselineControl", "mkactivity", "orderpatch", "acl", "search" ]

    constructor: (@adapter, @app, @prefix) ->
      @adapter ?= (path, method) -> path
      @prefix ?= ""
      @routes = []

    # Create a new CRUD resource with the given `name`, associated with the `controller`
    resource: (name, controller, options, callback) ->
      if typeof options is "function"
        callback = options
        options = null
      routes = [
        ["get", "new", "/#{name}/new"]
        ["post", "create", "/#{name}"]
        ["get", "show", "/#{name}/:#{name}_id"]
        ["get", "index", "/#{name}"]
        ["get", "edit", "/#{name}/:#{name}_id/edit"]
        ["put", "update", "/#{name}/:#{name}_id"]
        ["delete", "destroy", "/#{name}/:#{name}_id"]
      ]

      before = extract controller.before
      after = extract controller.after

      for route in routes
        if typeof controller[route[1]] is "function"
          b = filter before, route[1]
          a = filter after, route[1]
          @addRoute "#{route[1]}_#{name}", route[0], route[2], b..., controller[route[1]], a...

      r = new Router(@adapter, @app, @prefix + "/#{name}/:#{name}_id")
      callback?(r)
      return r

    # Create a new route within the router and add it to the app if already provided
    addRoute: (alias, method, endpoint, middlewares...) ->
      adapter = Router.adapt @prefix + endpoint, method, @adapter
      if @app?
        @app.locals.path ?= {}
        @app.locals.path[alias] = adapter
        @app[method](@prefix + endpoint, middlewares...)
      else
        @routes.push [alias, method, endpoint, adapter, middlewares...]

    # Add all existing and later routes to the express app given in parameters
    use: (@app) ->
      @routes.forEach (args) =>
        @addRoute args...

    # Add every HTTP method to the prototype of router as an alias of addRoute
    for method in @HTTPMethods
      Router.prototype[method] = do (method) ->
        (alias, endpoint, middlewares...) ->
          @addRoute alias, method, endpoint, middlewares...

    # Return a sub router
    scope: (prefix, callback) ->
      if prefix.charAt(0) != "/"
        prefix = "/" + prefix
      r = new Router(@adapter, @app, @prefix + prefix)
      callback?(r)
      return r


    # Transform a route into a function adapting parameters into a path
    @adapt = (endpoint, method, adapter) ->
      tokens = endpoint.split(/:[^/]+/)
      count = tokens.length - 1
      count = 0 if count < 0
      do (tokens, count) ->
        (args...) ->
          path = tokens[0]
          pos = 0
          while count-- > 0
            path += args[pos] + tokens[pos + 1]
            pos++
          path = adapter(path, method) if adapter?
          path
