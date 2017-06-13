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
      @options = []

      if Array.isArray options
        @addOption option, @user for option in options
      else if options?
        @addOption options, @user
      

    # Save the current state of the poll in the database
    save: ->
      db.save @id,
        owner: @user
        name: @name
        description: @description
        options: @options,
        (err, id) => @id = id


    # Add a new option to the poll
    addOption: (option, user) ->
      throw "An option must be a JSON object containing the field `description`" unless option.description?
      option.user = user
      option.count ?= 0
      option.description = option.description.trim()
      throw "An option with the same name already exists" if (o for o in @options when o.description == option.description).length != 0
      @options.push option


    # Remove the option with the description from the poll
    removeOption: (option) ->
      @options = @options.filter (e) -> e.description != option

      
    # Remove the poll from the database
    delete: ->
      throw "This poll is not registered in the database" unless @id?
      db.delete @id


module.exports = instanciatePoll
