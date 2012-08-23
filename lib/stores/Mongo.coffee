Store = require "../Store"

getId = =>
  rand = -> (((1 + Math.random()) * 0x10000000) | 0).toString 16
  return rand()+rand()+rand()

class Redis extends Store
  constructor: ({@id, @db, @size, @max}={}) ->
    super
    mongo = require 'mongoskin'
    @db ?= 'mongo://localhost:27017/silo?auto_reconnect'
    @id ?= getId()
    @size ?= 1000000
    @max ?= 1000000
    @subscribers = {}
    @conn = mongo.db @db

  getCollection: (k, fn) ->
    params =
      capped: true
      size: @size
      max: @max
    name = "#{@id}-#{k}"
    if fn?
      @conn.createCollection name, params, (err, coll) =>
        return fn err if err? and err.message isnt 'collection already exists'
        return fn null, @conn.collection name
    else
      @conn.collection name

  runSubscribers: (k, v) =>
    listener k, v for listener in @subscribers[k] if @subscribers[k]
    fn? null
    return @

  publish: (k, v, fn) ->
    @getCollection k, (err, coll) ->
      return fn? err if err?
      n = value: v
      coll.insert n, fn
    return @

  subscribe: (k, fn) ->
    unless @subscribers[k]
      @getCollection k, (err, coll) =>
        coll.find().sort($natural:-1).limit(1).nextObject (err, doc) =>
          nquery = (if doc? then {$gt:doc._id} else {})
          nqargs =
            tailable: true
            awaitdata: true
            numberOfRetries: -1

          poll = =>
            # tail every record newer than most recent
            coll.find nquery, nqargs, (err, cursor) =>
              cursor.each (err, val) => 
                return if err?
                return unless val? and val.value?
                @runSubscribers k, val.value
              # todo - watch capped coll instead of polling ffs
              setTimeout poll, 100 if @subscribers[k]?
          poll()
    (@subscribers[k]?=[]).push fn
    return @

  unsubscribe: (k, fn) ->
    if k?
      return @ unless @subscribers[k]
      if fn # unsub specific
        @subscribers[k] = (l for l in @subscribers[k] when l isnt fn)
      else # unsub channel
        delete @subscribers[k]
    else # unsub all
      @subscribers = {}
    return @

  get: (k, fn) ->
    @getCollection(@id).findOne {_id:k}, (err, doc) => fn err, doc?.value
    return @

  set: (k, v, fn) ->
    ndoc =
      _id: k
      value: v
    @getCollection(@id).save ndoc, (err, doc) => fn? err
    return @

  has: (k, fn) ->
    @getCollection(@id).findOne {_id:k}, (err, doc) => fn err, doc?
    return @

  del: (k, fn) ->
    @getCollection(@id).remove {_id:k}, (err, doc) => fn? err
    return @

  destroy: (fn) ->
    @getCollection(k).drop() for k,listeners of @subscribers
    @conn.close fn
    @subscribers = {}
    return @

module.exports = Redis