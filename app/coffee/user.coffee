bcrypt = require "bcrypt-nodejs"
ObjectId = require("mongodb").ObjectId

instanciateUser = (db) ->

  # #########################
  #       User model        #
  # #########################

  class User
    constructor: (@name, @email, @votes, @password) ->

    verifyPassword: (password) ->
      bcrypt.compareSync(password, @password)

    setPassword: (password) ->
      @password = bcrypt.hashSync(password, bcrypt.genSaltSync(8), null)

    save: (callback) ->
      db.save {
          _id: if @id then ObjectId(@id) else undefined
          username: @name
          email: @email
          vote: @votes
          password: @password
        }, (err, obj) =>
          return callback err if err
          @id = obj._id
          callback null, @

    @findOne = (params, callback) ->
      db.findOne params, (err, result) ->
        callback err if err
        user = false
        if result?
          user = new User(result.username, result.email, result.votes, result.password)
          user.id = result._id
        callback null, user

module.exports = instanciateUser
