pollControllerC = require "../../app/coffee/voting-app/poll_controller.coffee"


sinon = require "sinon"
assert = require("chai").assert

MockCollection = require "../helpers/db.coffee"
PollC = require("../../app/coffee/voting-app/poll.coffee")
UserC = require "../../app/coffee/user.coffee"
db = new MockCollection [ { name: "poll1", owner: "user1", description: "desc1" } ]
polls = db.values

Poll = PollC db, (x) -> x
User = UserC db
pollController = pollControllerC Poll

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

  afterEach ->
    database.restore()
    res.render.reset()
    res.redirect.reset()

  it "should render the global view on index", ->

    pollController.index(req, res)

    sinon.assert.calledOnce res.render
    sinon.assert.calledWith res.render, "polls/index.pug", user: req.user, polls: polls.map Poll.deserialize

  it "should render the individual view on show", ->
    req.params = { name: "poll1" }
    pollController.show(req, res)

    sinon.assert.calledOnce res.render
    poll = polls[0]
    sinon.assert.calledWith res.render, "polls/show.pug", user: req.user, poll: Poll.deserialize poll

  it "should render the individual edition view on edit", ->
    req.params = { name: "poll1" }
    pollController.edit(req, res)

    sinon.assert.calledOnce res.render
    poll = polls[0]
    sinon.assert.calledWith res.render, "polls/edit.pug", user: req.user, poll: Poll.deserialize poll

  it "should render the creation view on new", ->
    req.body = { name: "poll1" }
    pollController.new(req, res)

    sinon.assert.calledOnce res.render
    sinon.assert.calledWith res.render, "polls/new.pug", user: req.user

  it "should add a poll to the database on create", ->
    req.body = { name: "poll1", description: "desc1" }
    database.expects("save").once().withArgs new Poll("user1", "poll1", "desc1").serialize()
    pollController.create(req, res)
    database.verify()

  it "should redirect to the individual show page after create", ->
    req = body: {name: "poll1"}, user: new User("user1", "email")
    pollController.create(req, res)

    sinon.assert.calledOnce(res.redirect)
    sinon.assert.calledWith(res.redirect, "/voting-app/poll/poll1")

  it "should change a poll in the database on update", ->
    req.body = { name: "poll1", description: "desc1" }
    poll = Poll.deserialize(polls[0]).serialize() #transforming the object to fit the format used internally
    database.expects("save").once().withArgs poll
    pollController.update(req, res)
    database.verify()

  it "should redirect to the individual edit page after update", ->
    req = body: {name: "poll1"}, user: new User("user1", "email")
    pollController.update(req, res)
    sinon.assert.calledOnce(res.redirect)
    sinon.assert.calledWith(res.redirect, "/voting-app/poll/poll1/edit")

  it "should remove a poll from the database on destroy", ->
    req.body = { name: "poll1", description: "desc1" }
    database.expects("remove").once().withArgs polls[0]._id
    pollController.destroy(req, res)
    database.verify()

  it "should redirect to the index page on destroy", ->
    req = body: {name: "poll1"}, user: new User("user1", "email")
    pollController.destroy(req, res)
    sinon.assert.calledOnce(res.redirect)
    sinon.assert.calledWith(res.redirect, "/voting-app/polls")

