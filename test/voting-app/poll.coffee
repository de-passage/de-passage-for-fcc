chai = require("chai")
chai.should()

Poll = require "../../app/coffee/voting-app/poll.coffee"

class MockDB
  constructor: ->
    @ids = 0
    @count = 0

  save: (id, obj, callback) ->
    unless id?
      id = @ids
      @ids++
    unless @[id]?
      @count++
    @[id] = obj
    callback(null, id)

  delete: (id) ->
    if @[id]?
      delete @[id]
      @count--



describe "Poll", ->

  db = null

  beforeEach ->
    db = new MockDB

  it "should be constructible with a minimum number of parameters", ->
    poll = new Poll db, "user", "sample name"
    (typeof poll.db).should.not.equal "undefined"
    poll.user.should.equal "user"
    poll.name.should.equal "sample name"
    poll.options.should.be.an "array"
    poll.options.length.should.equal 0
    poll.description.should.equal ""

  it "should be possible to construct a poll with one option", ->
    poll = new Poll db, "", "", "", {description: "option1"}
    poll.options.length.should.equal 1
    poll.options[0].description.should.equal "option1"

  it "should be possible to construct a poll with several options", ->
    poll = new Poll db, "", "", "", [ {description: "option1"}, {description: "option2", count: 3}, {description: "option3"} ]
    poll.options.length.should.equal 3
    poll.options[0].description.should.equal "option1"
    poll.options[0].count.should.equal 0
    poll.options[1].description.should.equal "option2"
    poll.options[1].count.should.equal 3
    poll.options[2].description.should.equal "option3"
    poll.options[2].count.should.equal 0

  it "should be possible to add options to a poll", ->
    poll = new Poll db, "", ""
    poll.addOption { description: "option1" }
    poll.options.length.should.equal 1
    poll.addOption { description: "option2", count: 42 }
    poll.options.length.should.equal 2
    poll.options[0].description.should.equal "option1"
    poll.options[0].count.should.equal 0
    poll.options[1].description.should.equal "option2"
    poll.options[1].count.should.equal 42

  it "should be possible to remove options from a poll", ->
    poll = new Poll db, "", "", "", [ {description: "option1"}, {description: "option2"}, {description: "option3"} ]
    poll.removeOption "option2"
    poll.options.length.should.equal 2
    poll.options[0].description.should.equal "option1"
    poll.options[1].description.should.equal "option3"

  it "should be possible to save the current poll and retrieve the assigned id", ->
    poll = new Poll db, "user", "name", "description", [{description: "option1"}, {description: "option2"}]
    (typeof poll.id).should.equal "undefined"
    poll.save()
    db.count.should.equal 1
    (typeof db[0]).should.not.equal "undefined"
    poll.id.should.equal 0

