Router = require "../app/coffee/router.coffee"

chai = require "chai"
chai.should()
sinon = require "sinon"

describe "Router", ->
  router = null
  app = null
  Resource = {}
  methods = ["show", "update", "index", "create", "edit", "new", "destroy"]
  for verb in methods
    Resource[verb] = ->
  expectedPath = ["/resource/0", "/resource/0?_method=PUT", "/resource", "/resource", "/resource/0/edit", "/resource/new", "/resource/0?_method=DELETE"]

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

  checkResource = ->
    app.get.callCount.should.equal 4
    app.post.callCount.should.equal 1
    app.delete.callCount.should.equal 1
    app.put.callCount.should.equal 1

    for method, i in methods
      app.locals.path[method + "_resource"](0).should.equal expectedPath[i]

  it "should allow the definition of CRUD resources through the resource method", ->
    router.resource("resource", Resource)
    checkResource()


  it "should add the registered routes to the app on use", ->
    router = new Router customAdapter
    router.resource "resource", Resource
    router.use app

    checkResource()

  it "should allow to add new routes to the app after use", ->
    router = new Router customAdapter
    router.use app
    router.resource "resource", Resource

    checkResource()


  [ "before", "after" ].forEach (e) ->
    C =
      "#{e}": sinon.spy()
      show: sinon.spy()
      update: sinon.spy()
    get_f = []
    put_f = []
    ap =
      locals: {}
      get: (route, callbacks...) ->
        get_f = callbacks
      put: (route, callbacks...) ->
        put_f = callbacks
    f1 = sinon.spy()
    f2 = sinon.spy()

    it "should allow controllers to have a #{e} callback", ->
      router = new Router customAdapter, ap
      router.resource "resource", C
      get_f.length.should.equal 2
      put_f.length.should.equal 2
      for f in get_f
        f()

      if e == "after"
        sinon.assert.callOrder C.show, C.after
      else
        sinon.assert.callOrder C.before, C.show


    it "should allow controllers to have multiple #{e} callbacks", ->
      C[e] = [ f1, f2 ]
      router = new Router customAdapter, ap
      router.resource "", C

      get_f.length.should.equal 3
      put_f.length.should.equal 3
      for f in get_f
        f()
      if e == "after"
        sinon.assert.callOrder C.show, C.after...
      else
        sinon.assert.callOrder C.before..., C.show

    it "should allow a #{e} callback to have a `only` property defining #{e} which function the callbacks should be called", ->

      C[e] =
        use: f1
        only: ["show"]

      router = new Router customAdapter, ap
      router.resource "", C

      get_f.length.should.equal 2
      put_f.length.should.equal 1
      for f in get_f
        f()
      if e == "after"
        sinon.assert.callOrder C.show, f1
      else
        sinon.assert.callOrder f1, C.show

      for f in put_f
        f()
      if e == "after"
        sinon.assert.callOrder C.update
      else
        sinon.assert.callOrder C.update

      f1.reset()

    it "should allow a #{e} callback to have a `except` property defining #{e} which function the callbacks should not be called", ->
      C[e] =
        use: [f1, f2]
        except: ["show"]

      router = new Router customAdapter, ap
      router.resource "", C

      get_f.length.should.equal 1
      put_f.length.should.equal 3
      for f in get_f
        f()
      if e == "after"
        sinon.assert.callOrder C.show
      else
        sinon.assert.callOrder C.show
      for f in put_f
        f()
      if e == "after"
        sinon.assert.callOrder C.update, f1, f2
      else
        sinon.assert.callOrder f1, f2, C.update
      f1.reset()
      f2.reset()

    it "should allow #{e} callbacks to have different only/except properties", ->
      C[e] = [
        {
          use: f1
          only: "show"
        },
        {
          use: f2
          except: "show"
        }
      ]

      router = new Router customAdapter, ap
      router.resource "", C
      get_f.length.should.equal 2
      put_f.length.should.equal 2
      for f in get_f
        f()
      if e == "after"
        sinon.assert.callOrder C.show, f1
      else
        sinon.assert.callOrder f1, C.show
      for f in put_f
        f()
      if e == "after"
        sinon.assert.callOrder C.update, f2
      else
        sinon.assert.callOrder f2, C.update
      f1.reset()
      f2.reset()

  it "should accept a callback for resources which allows to define nested resources", ->
    SubResource =
      show: ->
      index: ->
      update: ->
      destroy: ->

    router.resource "resource", Resource, (r) ->
      r.resource "subresource", SubResource

    app.delete.callCount.should.equal 2
    app.put.callCount.should.equal 2
    app.get.callCount.should.equal 6

    app.locals.path.show_subresource(0, 0).should.equal "/resource/0/subresource/0"
    app.locals.path.index_subresource(0).should.equal "/resource/0/subresource"
    app.locals.path.update_subresource(0,0).should.equal "/resource/0/subresource/0?_method=PUT"
    app.locals.path.destroy_subresource(2,0).should.equal "/resource/2/subresource/0?_method=DELETE"

  it "should accept combinations of nested scopes and resources", ->
    SubResource =
      show: ->
      index: ->
      update: ->
      destroy: ->

    router.scope("scope").resource "resource", Resource, (r) ->
      r.resource "subresource", SubResource

    app.delete.callCount.should.equal 2
    app.put.callCount.should.equal 2
    app.get.callCount.should.equal 6

    app.locals.path.show_subresource(0, 0).should.equal "/scope/resource/0/subresource/0"
    app.locals.path.index_subresource(0).should.equal "/scope/resource/0/subresource"
    app.locals.path.update_subresource("test",0).should.equal "/scope/resource/test/subresource/0?_method=PUT"
    app.locals.path.destroy_subresource(2,0).should.equal "/scope/resource/2/subresource/0?_method=DELETE"
    app.locals.path.destroy_subresource(2,0).should.equal "/scope/resource/2/subresource/0?_method=DELETE"

  it "should accept a callback for scoping", ->
    router.scope "/scope", (r) ->
      r.get("res", "/resource", ->)
    app.locals.path.res().should.equal "/scope/resource"
    sinon.assert.calledOnce(app.get)

