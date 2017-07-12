pollControllerC = require "../../app/coffee/voting-app/poll_controller.coffee"


sinon = require "sinon"
assert = require("chai").assert

MockCollection = require "../helpers/db.coffee"
PollC = require("../../app/coffee/voting-app/poll.coffee")
UserC = require "../../app/coffee/user.coffee"

db = new MockCollection

Poll = PollC db, (x) -> x
User = UserC db
pollController = pollControllerC Poll
db_values = [ { name: "poll1", owner: "user1", description: "desc1" } ]
Poll.deserialize(value).save() for value in db_values
polls = db.values


describe "Poll controller", ->

  res =
    render: sinon.spy()
    redirect: sinon.spy()
  req = null
  database = null

  beforeEach ->
    database = sinon.mock(db)
    req =
      user:
        new User "user1", "email"
      flash: ->

  afterEach ->
    database.restore()
    res.render.reset()
    res.redirect.reset()

  it "should render the global view on index", ->

    pollController.index(req, res)

    sinon.assert.calledOnce res.render
    sinon.assert.calledWith res.render, "polls/index.pug", polls: polls.map(Poll.deserialize)

  it "should render the individual view on show", ->
    req.params = { name: "poll1" }
    req.get = ->
    pollController.show(req, res)

    sinon.assert.calledOnce res.render
    poll = polls[0]
    sinon.assert.calledWith res.render, "polls/show.pug", poll: Poll.deserialize(poll), hasVoted: false, url:"undefined://undefinedundefined"

  it "should render the individual edition view on edit", ->
    req.params = { name: "poll1" }
    pollController.edit(req, res)

    sinon.assert.calledOnce res.render
    poll = polls[0]
    sinon.assert.calledWith res.render, "polls/edit.pug", poll: Poll.deserialize(poll)

  it "should render the creation view on new", ->
    req.body = { name: "poll1" }
    pollController.new(req, res)

    sinon.assert.calledOnce res.render
    sinon.assert.calledWith res.render, "polls/new.pug"

  it "should add a poll to the database on create", ->
    req.body = { name: "poll1", description: "desc1" }
    expectedLength = db.values.length + 1
    pollController.create(req, res)
    assert(db.values.length == expectedLength, "Expected #{expectedLength} elements in the database, but had #{db.values.length})")

  it "should redirect to the individual show page after create", ->
    req = Object.assign req, body: {name: "poll1"}
    pollController.create(req, res)

    sinon.assert.calledOnce(res.redirect)
    sinon.assert.calledWith(res.redirect, "/voting-app/poll/poll1")

  it "should change a poll in the database on update", ->
    req = { params: { name: "poll1", description: "desc1" }, body: { } }
    poll = polls[0]
    database.expects("save").once().withArgs poll
    pollController.update(req, res)
    database.verify()

  it "should redirect to the individual show page after update", ->
    req = params: {name: "poll1"}, body: {}
    pollController.update(req, res)
    sinon.assert.calledOnce(res.redirect)
    sinon.assert.calledWith(res.redirect, "/voting-app/poll/poll1")

  it "should remove a poll from the database on destroy", ->
    req.params = { name: "poll1", description: "desc1" }
    database.expects("remove").once().withArgs _id: polls[0]._id
    pollController.destroy(req, res)
    database.verify()

  it "should redirect to the index page on destroy", ->
    req.params =  {name: "poll1"}
    pollController.destroy(req, res)
    sinon.assert.calledOnce(res.redirect)
    sinon.assert.calledWith(res.redirect, "/voting-app/polls")

