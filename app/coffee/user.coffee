bcrypt = require "bcrypt-nodejs"
ObjectId = require("mongodb").ObjectId

instanciateUser = (db) ->

  # #########################
  #       User model        #
  # #########################

  class User
    constructor: (@name, @email, @password, @visit) ->
      @visit ?= {}

    verifyPassword: (password) ->
      bcrypt.compareSync(password, @password)

    setPassword: (password) ->
      @password = bcrypt.hashSync(password, bcrypt.genSaltSync(8), null)

    save: (callback) ->
      db.save {
          _id: if @id then ObjectId(@id) else undefined
          username: @name
          email: @email
          password: @password
          visit: @visit
        }, (err, obj) =>
          return callback? err if err
          @id = obj._id
          callback? null, @

    @findOne = (params, callback) ->
      db.findOne params, (err, result) ->
        callback err if err
        user = false
        if result?
          user = new User(result.username, result.email, result.password, result.visit)
          user.id = result._id
        callback null, user

    @aggregateVisits = (venues) ->
      new Promise (resolve, reject) ->
        db.find( { visit: $in: venues }, { visit: 1, username: 1 } ).toArray (err, arr) ->
          return reject err if err
          return resolve [] unless arr
          res = {}
          for venue in venues
            res[venue] = []
          for e in arr
            res[e.visit].push e.username

          resolve res

module.exports = instanciateUser
