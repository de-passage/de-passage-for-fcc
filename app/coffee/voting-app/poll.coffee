ObjectId = require("mongodb").ObjectId

instanciatePoll = (db) ->
# #####################
# Model for the polls #
# #####################

  class Poll

    # Builds a new poll. 
    # Requires a database adapter with the right interface, a user and a name
    # May have a description and options
    constructor: (@user, @name, @description, options) ->
      throw "Not owner specified" unless @user?
      throw "Not name specified" unless @name?

      @description ?= ""
      @options = {}
      @voters = {}

      if Array.isArray options
        @addOption option, @user for option in options
      else if options?
        @addOption options, @user
      

    # Save the current state of the poll in the database
    save: (callback) ->
      db.save {
        _id: if @id then ObjectId(@id) else undefined
        owner: @user
        name: @name
        description: @description
        options: @options
        voters: @voters
      }, (err, obj) =>
        return callback err if err
        @id = obj._id
        callback null, @
        


    # Add a new option to the poll
    addOption: (name, user) ->
      option =
        user: user
        count: 0
      option.description = option.description.trim()
      throw "An option with the name '#{name}' already exists" if options[name]
      @options[name] option


    # Remove the option with the description from the poll
    removeOption: (option) ->
      @options = @options.filter (e) -> e.description != option

    # Register a user's vote for an option
    vote: (option, username) ->
      throw "Option '#{option}' does not exist" unless @options[option]?
      if @voter[username]?
        @options[@voter[username]].count--
      @options[option].count++
      @voter[username] = option
      

      
    # Remove the poll from the database
    delete: ->
      throw "This poll is not registered in the database" unless @id?
      db.delete @id

    @findOne: (search, callback) ->
      db.findOne search, (err, poll) ->
        callback err if err
        result = false
        if poll
          result = new Poll poll.owner, poll.name, poll.description
          result.id = poll._id
          result.options = poll.options
          result.voters = poll.voters
        callback null, result

        




module.exports = instanciatePoll
