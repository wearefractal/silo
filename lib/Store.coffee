class Store
  constructor: (@options={}) ->
  publish: (k, v, fn) ->
  subscribe: (k, fn) ->
  unsubscribe: (k, fn) ->
  get: (k, fn) ->
  set: (k, v, fn) ->
  has: (k, fn) ->
  del: (k, fn) ->
  destroy: (fn) ->

module.exports = Store