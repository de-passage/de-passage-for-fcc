pollControllerC = require "../../app/coffee/voting-app/poll_controller.coffee"

MockCollection = require "../helpers/db.coffee"

sinon = require "sinon"

PollC = require("../../app/coffee/voting-app/poll.coffee")
polls = [ { name: "poll1", owner: "user1", description: "desc1" } ]
db = new MockCollection polls
Poll = PollC db

pollController = pollControllerC Poll

assert = require("chai").assert

describe "Poll controller", ->

  res =
    render: sinon.spy()
    redirect: sinon.spy()
  req = null

  beforeEach ->
    req =
      user:
        name: "username"

  afterEach ->
    res.render.reset()

  it "should render the global view on index", ->

    pollController.index(req, res)

    sinon.assert.calledOnce res.render
    sinon.assert.calledWith res.render, "index_polls.pug", user: req.user, polls: polls.map Poll.deserialize

  it "should render the individual view on show", ->
    req.params = { name: "poll1" }
    pollController.show(req, res)

    sinon.assert.calledOnce res.render
    poll = polls[0]
    sinon.assert.calledWith res.render, "show_poll.pug", user: req.user, poll: Poll.deserialize poll

  it "should render the individual edition view on edit", ->
    req.params = { name: "poll1" }
    pollController.edit(req, res)

    sinon.assert.calledOnce res.render
    poll = polls[0]
    sinon.assert.calledWith res.render, "edit_poll.pug", user: req.user, poll: Poll.deserialize poll

  it "should render the creation view on new", ->
    req.params = { name: "poll1" }
    pollController.new(req, res)

    sinon.assert.calledOnce res.render
    sinon.assert.calledWith res.render, "new_poll.pug", user: req.user

  it "should add a poll to the database on create"

  it "should redirect to the individual show page after create", ->
    req = {}
    pollController.create(req, res)

    sinon.assert.calledOnce(res.redirect)

  it "should change a poll in the database on update"

  it "should redirect to the individual edit page after update"

  it "should remove a poll from the database on destroy"

  it "should redirect to the index page on destroy"
