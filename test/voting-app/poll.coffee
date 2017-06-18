chai = require("chai")
chai.should()

class MockDB
  constructor: ->
    @ids = 0
    @count = 0

  save: (obj, callback) ->
    id = obj.id
    unless id?
      id = @ids
      @ids++
    unless @[id]?
      @count++
    @[id] = obj
    callback(null, {_id: id})

  delete: (id) ->
    if @[id]?
      delete @[id]
      @count--

Poll = null

describe "Polls", ->

  db = null

  beforeEach ->
    db = new MockDB
    Poll = require("../../app/coffee/voting-app/poll.coffee")(db)

  it "should be constructible with a minimum number of parameters", ->
    poll = new Poll "user", "sample name"
#    (typeof poll.db).should.not.equal "undefined"
    poll.user.should.equal "user"
    poll.name.should.equal "sample name"
    poll.options.should.be.an "object"
    poll.optionCount().should.equal 0
    poll.description.should.equal ""

  it "should be constructible with one option", ->
    poll = new Poll "", "", "", {description: "option1"}
    poll.optionCount().should.equal 1
    poll.options["option1"].count.should.equal 0

  it "should be constructible with several options", ->
    poll = new Poll "", "", "", [ {description: "option1"}, {description: "option2", count: 3}, {description: "option3"} ]
    poll.optionCount().should.equal 3
    poll.options["option1"].count.should.equal 0
    poll.options["option2"].count.should.equal 3
    poll.options["option3"].count.should.equal 0

  it "should add new options through the addOption() method", ->
    poll = new Poll "", ""
    poll.addOption { description: "option1" }
    poll.optionCount().should.equal 1
    poll.addOption { description: "option2", count: 42 }
    poll.optionCount().should.equal 2
    poll.options["option1"].count.should.equal 0
    poll.options["option2"].count.should.equal 42

  it "should remove options through the removeOption() method", ->
    poll = new Poll "", "", "", [ {description: "option1"}, {description: "option2"}, {description: "option3"} ]
    poll.removeOption "option2"
    poll.optionCount().should.equal 2
    poll.options["option1"].count.should.equal 0
    poll.options["option3"].count.should.equal 0
    (typeof poll.options["option2"]).should.equal "undefined"

  it "should be saved to the database through the save() method", ->
    poll = new Poll "user", "name", "description", [{description: "option1"}, {description: "option2"}]
    (typeof poll.id).should.equal "undefined"
    poll.save (err, poll) ->
      db.count.should.equal 1
      (typeof db[0]).should.not.equal "undefined"
      poll.id.should.equal 0

