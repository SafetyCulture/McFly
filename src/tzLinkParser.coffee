streamTransform = require 'stream-transform'
csvParse = require 'csv-parse'
async = require 'async'

TzTsvTranform = require './tzTsvTransform'

ACCEPTED_TYPE = "Link"

# Configuration for the CSV parser to accept the IANA TZ DB Link format.
PARSER_OPTIONS =
  delimiter: '	',
  comment: '#',
  trim: true,
  columns: ["type", "target", "link"],
  skip_empty_lines: true

# Parses an individual stream with node-csv, extracting a series of fields from IANA TZ DB Link formatted documents.
#
# @param [ReadableStream] stream A ReadableStream of data in the IANA TZ DB Link format.
# @param [Function] callback Function to call when this parsing the given stream is complete. This method should have
#   the following signature: (error, results).
_parseIndividualStream = (stream, callback) ->
  # Parse a stream into a usable format from a stream
  results = []

  parser = csvParse PARSER_OPTIONS

  resultTransform = streamTransform (record, callback) ->
    results.push record
    callback null

  parser.on 'error', (error) ->
    callback error

  parser.on 'finish', ->
    callback null, results

  stream.pipe(new TzTsvTranform).pipe(parser).pipe(resultTransform)

# Parses one or more streams into a single object describing the required timezone conversions.
#
# @param [ReadableStream|Array] streams One of more ReadableStreams of data in the IANA TZ DB Link format.
# @param [Function] callback Function to call when parsing the given streams is complete. This method should have
#   the following signature: (error, results).
parse = (streams, callback) ->
  conversions = {}

  # Check if this is an array, if not add it to an array.
  if not Array.isArray(streams)
    streams = [streams]

  async.map streams, _parseIndividualStream, (error, results) ->
    return callback error if error?

    for fileResult in results
      for result in fileResult
        if result.type? and result.type == ACCEPTED_TYPE and result.target? and result.target != "" and
        result.link? and result.link != ""
          conversions[result.link] = result.target

    callback null, conversions

module.exports = {parse}