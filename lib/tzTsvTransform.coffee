stream = require 'stream'

# Stream Transform class for cleaning up the duplicate tabs found in the IANA TZ TSV files.
#
# @extend stream.Transform
#
class TzTsvTranform extends stream.Transform

  # Function to transform chunks of input data. Only to be called by internal stream methods.
  #
  # @param [Buffer] chunk Chunk of data that has been read from the incoming stream
  # @param [string] encoding Encoding of the data
  # @param [Function] callback Function to call when this transform is complete
  _transform: (chunk, encoding, callback) ->
    # Searches for tabs and multiple tabs and replaces them with a single tab.
    @push chunk.toString().replace(/\t+/g, ' ')
    callback()

module.exports = TzTsvTranform