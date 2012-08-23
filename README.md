![status](https://secure.travis-ci.org/wearefractal/silo.png?branch=master)

## Information

<table>
<tr> 
<td>Package</td><td>silo</td>
</tr>
<tr>
<td>Description</td>
<td>Generic PubSub storage adapters</td>
</tr>
<tr>
<td>Node Version</td>
<td>>= 0.4</td>
</tr>
</table>

Tired of writing the same logic for dealing with storage over and over? Don't need the complex Schema layer an ORM provides? silo is the solution you're looking for.

## Usage

Each storage adapter implements the same set of functions. silo has a set of very strict tests to make sure each adapter functions the same way.

```coffee-script
silo = require 'silo'
store = new silo.<Adapter Name>()
store.set 'key', 'val', (err) ->
store.get 'key', (err, val) -> 
store.has 'key', (err, exists) ->
store.del 'key', (err) ->

myFn = (key, val) ->
store.subscribe 'channel', myFn # listen to channel for message
store.unsubscribe 'channel', myFn # unsubscribe listener
store.unsubscribe 'channel' # unsubscribe all listeners for channel
store.unsubscribe() # unsubscribe everything

store.publish 'channel', 'message!' # publish message to channel

store.destroy (err) ->
```

## Available Adapters

### Memory

```coffee-script
store = new silo.Memory()
```

### Redis

```coffee-script
redis = require 'redis'
store = new silo.Redis
  main: redis.createClient()
  pub: redis.createClient()
  sub: redis.createClient()
```

### MongoDB

```coffee-script
store = new silo.Mongo
  db: 'mongo://localhost:27017/silo?auto_reconnect'
```

## LICENSE

(MIT License)

Copyright (c) 2012 Fractal <contact@wearefractal.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
