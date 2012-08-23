Store = require "../Store"

class Memory extends Store
  constructor: ->
    super
    @data = {}
    @subscribers = {}

  publish: (k, v, fn) ->
    listener k, v for listener in @subscribers[k] if @subscribers[k]
    fn? null
    return @

  subscribe: (k, fn) ->
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
    fn null, @data[k]
    return @

  set: (k, v, fn) ->
    @data[k] = v
    fn? null
    return @

  has: (k, fn) ->
    fn null, @data[k]?
    return @

  del: (k, fn) -> @set k, undefined, fn

  destroy: (fn) ->
    @data = {}
    fn? null
    return @

module.exports = Memory