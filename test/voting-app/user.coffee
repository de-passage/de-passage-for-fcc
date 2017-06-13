require("chai").should()

db = new class MockDB
  save: ->
    console.log "saved"

User = require("../../app/coffee/voting-app/user.coffee")(db)

describe "User", ->
  it "should print saved", ->
    user = new User
    user.save()
