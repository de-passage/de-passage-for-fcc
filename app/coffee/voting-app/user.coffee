
instanciateUser = (db) ->

  # #########################
  #       User model        #
  # #########################

  class User
    constructor: ->
      @name = ""
      @votes = []
      @id = null

    isAuthenticated: ->
      false

    save: ->
      db.save()

module.exports = instanciateUser
