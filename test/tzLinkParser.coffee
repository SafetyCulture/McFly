assert = require 'assert'
stream = require 'stream'

tzLinkParser = require '../lib/tzLinkParser'

describe 'tzLinkParser', ->

  ###
    parse()
    Should accept a stream of IANA TZ Link file data and output a structured object of the conversions required.
  ###

  describe 'parse()', ->

      it 'should accept and extract data for a single stream', (done) ->
        expected =
          'Deprecated': "Etc/Modern"

        parseStream = new stream.PassThrough()

        parseStream.on 'error', (error) ->
          done error

        tzLinkParser.parse parseStream, (error, results) ->
          return done error if error?
          assert.deepEqual results, expected
          done null

        parseStream.write("Link	Etc/Modern	Deprecated")
        parseStream.end()

      it 'should accept and extract data for a multiple streams', (done) ->
        expected =
          'Deprecated': "Etc/Modern"
          'Deprecated2': "Etc/Modern2"

        parseStream1 = new stream.PassThrough()
        parseStream2 = new stream.PassThrough()

        parseStream1.on 'error', (error) ->
          done error

        parseStream2.on 'error', (error) ->
          done error

        tzLinkParser.parse [parseStream1, parseStream2], (error, results) ->
          return done error if error?
          assert.deepEqual results, expected
          done null

        parseStream1.write("Link	Etc/Modern	Deprecated")
        parseStream2.write("Link	Etc/Modern2	Deprecated2")
        parseStream1.end()
        parseStream2.end()

      it 'should ignore rows of data which are not of type "Link"', (done) ->
        expected =
          'Deprecated': "Etc/Modern"
          'Deprecated2': "Etc/Modern2"

        parseStream = new stream.PassThrough()

        parseStream.on 'error', (error) ->
          done error

        tzLinkParser.parse parseStream, (error, results) ->
          return done error if error?
          assert.deepEqual results, expected
          done null

        parseStream.write("Link	Etc/Modern	Deprecated\n")
        parseStream.write("NotLink	Etc/Bad	Bad\n")
        parseStream.write("Link	Etc/Modern2	Deprecated2")
        parseStream.end()

      it 'should ignore commented lines', (done) ->
        expected =
          'Deprecated': "Etc/Modern"
          'Deprecated2': "Etc/Modern2"

        parseStream = new stream.PassThrough()

        parseStream.on 'error', (error) ->
          done error

        tzLinkParser.parse parseStream, (error, results) ->
          return done error if error?
          assert.deepEqual results, expected
          done null

        parseStream.write("Link	Etc/Modern	Deprecated\n")
        parseStream.write("# This is a comment line \n")
        parseStream.write("Link	Etc/Modern2	Deprecated2")
        parseStream.end()

      it 'should ignore empty lines', (done) ->
        expected =
          'Deprecated': "Etc/Modern"
          'Deprecated2': "Etc/Modern2"

        parseStream = new stream.PassThrough()

        parseStream.on 'error', (error) ->
          done error

        tzLinkParser.parse parseStream, (error, results) ->
          return done error if error?
          assert.deepEqual results, expected
          done null

        parseStream.write("Link	Etc/Modern	Deprecated\n")
        parseStream.write("\n")
        parseStream.write("Link	Etc/Modern2	Deprecated2")
        parseStream.end()

      it 'should ignore lines missing data', (done) ->
        expected =
          'Deprecated': "Etc/Modern"

        parseStream = new stream.PassThrough()

        parseStream.on 'error', (error) ->
          done error

        tzLinkParser.parse parseStream, (error, results) ->
          return done error if error?
          assert.deepEqual results, expected
          done null

        parseStream.write("Link	Etc/Modern	Deprecated\n")
        parseStream.write("Link	Etc/Modern2	")
        parseStream.end()

      it 'should overwrite values with the last target read', (done) ->
        expected =
          'Deprecated': "Etc/ModernOverwritten"
          'Deprecated2': "Etc/Modern2"

        parseStream = new stream.PassThrough()

        parseStream.on 'error', (error) ->
          done error

        tzLinkParser.parse parseStream, (error, results) ->
          return done error if error?
          assert.deepEqual results, expected
          done null

        parseStream.write("Link	Etc/Modern	Deprecated\n")
        parseStream.write("Link	Etc/Modern2	Deprecated2\n")
        parseStream.write("Link	Etc/ModernOverwritten	Deprecated")
        parseStream.end()

