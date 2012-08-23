Store = require "../Store"

getId = =>
  rand = -> (((1 + Math.random()) * 0x10000000) | 0).toString 16
  return rand()+rand()+rand()

class Redis extends Store
  constructor: ({@id, @pub, @sub, @main}={}) ->
    super
    throw 'Missing required redis clients' unless @pub and @sub and @main
    @id ?= getId()
    @pack ?= JSON.stringify
    @unpack ?= JSON.parse
    @subscribers = {}
    @sub.on 'message', @runSubscribers

  runSubscribers: (k, v) =>
    v = @unpack v
    listener k, v for listener in @subscribers[k] if @subscribers[k]
    fn? null
    return @

  publish: (k, v, fn) ->
    @pub.publish k, @pack v
    fn? null
    return @

  subscribe: (k, fn) ->
    @sub.subscribe k
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
    @main.hget @id, k, fn
    return @

  set: (k, v, fn) ->
    @main.hset @id, k, v, fn
    return @

  has: (k, fn) ->
    @main.hexists @id, k, (err, has) ->
      return fn err if err
      fn null, !!has
    return @

  del: (k, fn) ->
    @main.hdel @id, k, fn
    return @

  destroy: (fn) ->
    @pub.end()
    @sub.end()
    @main.end()
    @subscribers = {}
    fn? null
    return @

module.exports = Redis