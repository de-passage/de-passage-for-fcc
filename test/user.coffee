userClass = require("../app/coffee/user.coffee")

chai = require("chai")
chai.should()
assert = chai.assert

sinon = require "sinon"

MockCollection = require "./helpers/db.coffee"
database = new MockCollection [ { name: "user1" } ]
User = userClass database
db = sinon.mock database

describe "User", ->

  afterEach ->
    db.verify()
    db.restore()

  it "should call the database save() method on save", ->
    expectedParameters =
      username: "name"
      email: "email"
      password: "password"
      _id: undefined
      visit: { }
    user = new User expectedParameters.username, expectedParameters.email, expectedParameters.password

    db.expects("save").once().withArgs expectedParameters
    user.save()

  it "should be possible to set a password and test it", ->
    user = new User
    user.setPassword "password"
    assert user.verifyPassword "password"
