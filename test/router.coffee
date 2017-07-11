Router = require "../app/coffee/router.coffee"

chai = require "chai"
chai.should()
sinon = require "sinon"

describe "Router", ->
  router = null
  app = null

  routes = [
    ["get", "/resource", [], "/resource"]
    ["post", "/resource/:id", ["param"], "/resource/param"]
    ["put", "/resource/:id/sub", ["param"], "/resource/param/sub"]
    ["delete", "/resource/:id/sub/:id2", ["param", "param2"], "/resource/param/sub/param2"]
  ]
  customAdapter = (path, method) ->
    if method not in ["get", "post"]
      path += "?_method=" + method.toUpperCase()
    path

  beforeEach ->
    app = locals: {}
    for e in Router.HTTPMethods
      app[e] = sinon.spy()
    router = new Router customAdapter, app

  afterEach ->
    for e in Router.HTTPMethods
      app[e].reset()
    

  it "should transform routes into functions with Router.adapt", ->
    for r in routes
      [method, route, params, result] = r
      Router.adapt(route, method).apply(null, params).should.equal result

  it "should adapt a route applying a custom adapter if provided", ->
    for r, i in routes
      [method, route, params, result] = r
      result = customAdapter result, method
      Router.adapt(route, method, customAdapter).apply(null, params).should.equal result

  it "should add routes to app.locals on addRoute", ->
    (typeof app.locals.path).should.equal "undefined"
    router.addRoute("show_resource", "get", "/resource", ->)
    app.locals.path.show_resource().should.equal "/resource"
    router.addRoute("update_resource", "put", "/resource/:id")
    app.locals.path.update_resource(0).should.equal "/resource/0?_method=PUT"

  it "should call the appropriate method on app when addRoute is used", ->
    for r in routes
      [method, route] = r
      router.addRoute(method + "_resource", method, route, ->)
      sinon.assert.calledOnce(app[method])

  it "should expose HTTP methods as short-hand to addRoute", ->
    for r in routes
      [method, route, params, result] = r
      router[method](method + "_resource", route, ->)
      sinon.assert.calledOnce(app[method])
      app.locals.path[method + "_resource"].apply(null, params).should.equal customAdapter(result, method)

  it "should prefix all routes when scoped", ->
    router.scope("/scope").get("res", "/resource", ->)
    app.locals.path.res().should.equal "/scope/resource"
    sinon.assert.calledOnce(app.get)
