silo = require '../'
should = require 'should'
redis = require 'redis'
require 'mocha'

for adapter,v of silo when adapter isnt 'Store'
  do (adapter) ->
    getAdapter = ->
      switch adapter
        when 'Redis'
          return new silo[adapter]
            main: redis.createClient()
            pub: redis.createClient()
            sub: redis.createClient()
        else
          return new silo[adapter]

    describe adapter, ->
      describe 'construct()', ->
        it 'should create', (done) ->
          test = getAdapter()
          should.exist test
          done()

      describe 'set()', ->
        it 'should set without error', (done) ->
          test = getAdapter()
          should.exist test
          
          test.set 'hello', 'world', (err) ->
            should.not.exist err
            done()

      describe 'get()', ->
        it 'should get without error', (done) ->
          test = getAdapter()
          should.exist test
          test.set 'hello', 'world', (err) ->
            should.not.exist err
            test.get 'hello', (err, val) ->
              should.not.exist err
              should.exist val
              val.should.equal 'world'
              done()

      describe 'has()', ->
        it 'should return true without error', (done) ->
          test = getAdapter()
          should.exist test
          
          test.set 'hello', 'world', (err) ->
            should.not.exist err
            test.has 'hello', (err, has) ->
              should.not.exist err
              should.exist has
              has.should.be.true
              done()

      describe 'del()', ->
        it 'should delete without error', (done) ->
          test = getAdapter()
          should.exist test
          
          test.set 'hello', 'world', (err) ->
            should.not.exist err
            test.del 'hello', (err) ->
              should.not.exist err
              test.has 'hello', (err, has) ->
                should.not.exist err
                should.exist has
                has.should.be.false
                done()

      describe 'subscribe()', ->
        it 'should subscribe without error', (done) ->
          test = getAdapter()
          should.exist test
          test.subscribe 'hello', (k, v) ->
            should.exist k
            should.exist v
            k.should.equal 'hello'
            v.should.equal 'world'
            test.unsubscribe 'hello'
            done()

          test.publish 'hello', 'world', (err) ->
            should.not.exist err

      describe 'unsubscribe()', ->
        it 'should unsubscribe without error', (done) ->
          test = getAdapter()
          should.exist test
          fn = -> throw 'Failed to unsubscribe'
          test.subscribe 'hello', fn
          test.unsubscribe 'hello', fn
          test.publish 'hello', 'world', (err) ->
            should.not.exist err
            done()

        it 'should unsubscribe channel without error', (done) ->
          test = getAdapter()
          should.exist test
          fn = -> throw 'Failed to unsubscribe'
          test.subscribe 'hello', fn
          test.unsubscribe 'hello'
          test.publish 'hello', 'world', (err) ->
            should.not.exist err
            done()

        it 'should unsubscribe all without error', (done) ->
          test = getAdapter()
          should.exist test
          fn = -> throw 'Failed to unsubscribe'
          test.subscribe 'hello', fn
          test.unsubscribe()
          test.publish 'hello', 'world', (err) ->
            should.not.exist err
            done()