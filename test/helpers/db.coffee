class Cursor
  constructor: (@ref) ->

  limit: ->
    @
  toArray: (callback) ->
    callback @ref

class MockCollection
  constructor: (@values) ->
  save: (obj, callback) ->
    callback(null, obj)

  findOne: (params, callback) ->
    callback null, @values[0]

  find: ->
    new Cursor(@values)

module.exports = MockCollection
