assert = require 'assert'
TzTsvTranform = require '../lib/tzTsvTransform'

describe 'tzLinkTransform', ->

  ###
    _transform()
    Should accept chunks of data and clean these chunks outputting a cleanly formatted TSV.
  ###

  describe '_transform()', ->

      it 'should strip duplicate, triplicate and any repeated tabs', (done) ->
        input = [
          "Link	Etc/GMT			GMT0",
          "# Commented line with spaces",
          "Link	America/Indiana/Knox	America/Knox_IN"
        ]
        expected = [
          "Link	Etc/GMT	GMT0",
          "# Commented line with spaces",
          "Link	America/Indiana/Knox	America/Knox_IN"
        ]

        output = []
        transform = new TzTsvTranform()

        transform.on 'readable', ->
          while record = transform.read()
            output.push(record)

        transform.on 'error', (error) ->
          done error

        transform.on 'finish', (error) ->
          assert.equal output.toString(), expected
          done()

        for inputItem in input
          inputBuffer = new Buffer(inputItem, 'utf8')
          transform.write(inputBuffer)

        transform.end()


