class Cursor
  constructor: (@ref) ->

  limit: ->
    @
  toArray: (callback) ->
    callback null, @ref

class MockCollection
  constructor: (values) ->
    @values = []
    @ids = 0
    @save value for value in values if values?


  save: (obj, callback) ->
    if obj._id?
      id = obj._id
      idx = i for v, i in @values
      @values[idx]._id = obj
    else
      id = obj._id = @ids
      @ids++
    @values.push obj
    callback?(null, obj)

  findOne: (params, callback) ->
    callback null, @values[0]

  find: ->
    new Cursor(@values)

  remove: ->

module.exports = MockCollection
