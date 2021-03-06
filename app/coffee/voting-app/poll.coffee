#ObjectId = require("mongodb").ObjectId

instanciatePoll = (db, ObjectId) ->
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
      db.save @serialize(), (err, obj) =>
        if callback?
          return callback err if err
          @id = obj._id
          callback null, @
        else
          throw err if err
          @id = obj._id



    # Add a new option to the poll
    addOption: (option, user) ->
      name = option.description.trim()
      throw "An option with the name '#{name}' already exists" if @options[name]
      newOption =
        user: user
        count: option.count || 0
        color: option.color || "#CCCCCC"
        border: option.border || "#444444"
      @options[name] = newOption


    # Remove the option with the description from the poll
    removeOption: (option) ->
      delete @options[option]

    # Register a user's vote for an option
    vote: (option, username) ->
      throw "Option '#{option}' does not exist" unless @options[option]?
      if @voters[username]?
        @options[@voters[username]].count--
      @options[option].count++
      @voters[username] = option

    hasVoted: (username) ->
      @voters[username]?

    optionCount: ->
      Object.keys(@options).length

    replaceOptions: (newOptions, user) ->
      console.log "Replacing with ", newOptions
      @options = {}
      for key, value of newOptions
        @addOption value, user
      for name, vote of @voters
        unless @options[vote]?
          delete @voters[name]

    # Remove the poll from the database
    delete: ->
      throw "This poll is not registered in the database" unless @id?
      db.remove _id: ObjectId @id

    # Transform a JSON object into a Poll
    @deserialize: (obj) ->
      poll = new Poll obj.owner, obj.name, obj.description
      poll.id = obj._id if obj._id?

      optionsRaw = if obj.options? then obj.options else []
      votersRaw = if obj.voters? then obj.voters else []
      options = {}
      voters = {}
      for option in optionsRaw
        options[option.name] = option.details

      for voter in votersRaw
        voters[voter.name] = voter.vote

      poll.options = options
      poll.voters = voters
      poll.created_at = obj.created_at
      poll

    #Transform a poll into a JSON object
    serialize: () ->
      voters =
        (name: key, vote: value for key, value of  @voters)
        
      options =
        (name: key, details: value for key, value of @options)

      obj =
        owner: @user
        name: @name
        description: @description
        options: options
        voters: voters
        created_at: @created_at || (new Date).getTime()
      obj._id = ObjectId(@id) if @id?
      obj

    @findOne: (search, callback) ->
      db.findOne search, (err, poll) =>
        callback err if err
        result = false
        if poll
          result = @deserialize poll
        callback null, result

    @all: (limit, callback) ->
      cursor = db.find({})
      if typeof limit is "function"
        callback = limit
      else
        cursor = cursor.limit(limit)
      cursor.toArray (err, arr) =>
        return callback err if err
        arr ||= []
        callback null, arr.map @deserialize

    @find: (search, callback) ->
      db.find(search).toArray (err, arr) =>
        return callback err if err
        arr ||= []
        callback null, arr.map @deserialize
        

module.exports = instanciatePoll

