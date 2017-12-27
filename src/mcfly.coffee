path = require 'path'
fs = require 'fs'
conversionParser = require './tzLinkParser'

defaultPath =

defaultOptions =
  conversions: path.join(__dirname, "../conversions")
  ignore: null

# The conversion cache houses already loaded conversions from the filesystem for reuse.
_conversionCache = {}

# Loads and parses an IANA TZ DB Link file/s into a McFly compatible conversion object. If given a file path it will
# load a single file, if given a directory path it will load all files in the directory.
#
# @param [string] conversionPath A file or directory path to the IANA TZ DB Link file/files
# @param [Function] callback Function to call when parsing the given file path is complete. This method should have
#   the following signature: (error, results).
_loadConversionFiles = (conversionPath, callback) ->
  conversionPath = path.resolve conversionPath

  # Return a copy from the cache if we have it loaded already.
  if _conversionCache[conversionPath]?
    return callback null, _conversionCache[conversionPath]

  fs.stat conversionPath, (error, stat) ->
    return callback error if error?

    if stat.isDirectory()
      # Extract all the files in the directory.
      fs.readdir conversionPath, (error, files) ->
        return callback error if error?

        conversionStreams = []
        for file in files
          fileStream = fs.createReadStream path.join conversionPath, file
          fileStream.on error, callback
          conversionStreams.push fileStream

        conversionParser.parse conversionStreams, (error, results) ->
          return callback error if error?
          _conversionCache[conversionPath] = results
          callback error, results
    else
      # Pass the parser the stream.
      conversionStream = fs.createReadStream conversionPath
      conversionParser.parse conversionStream, callback

# Given a conversion object and a timezone string will convert the given timezone string to a target string if
#
# @param [Object] conversions An object where keys are deprecated timezone strings where the value corresponds to their
#   linked target string.
# @param [string] oldTimezoneString The current timezone string to be transformed if necessary.
_convertTimezoneString = (conversions, oldTimezoneString) ->
  if conversions[oldTimezoneString]?
    return conversions[oldTimezoneString]
  else
    return oldTimezoneString

# Parses one or more streams into a single object describing the required timezone conversions.
#
# @param [string] oldTimezoneString The current timezone string to be transformed if necessary.
# @param [object] options Conversion options (optional)
# @option options [string|Object] conversions A file or directory path to the IANA TZ DB Link file/files OR an object
#   where keys are deprecated timezone strings where the value corresponds to their linked target string.
# @option options [regex] ignore A regular expression defining any old timezone strings which should be ignored for
#   conversion.
# @param [Function] callback Function to call when parsing the given streams is complete. This method should have
#   the following signature: (error, results).
convert = (oldTimezoneString, options, callback) ->
  # Options is an optional arg, rearrange and use the default options when its not provided.
  if not callback?
    callback = options
    options = defaultOptions

  # Ignore any timezones matching the following pattern. These can be resolved immediately.
  if options.ignore?
    if oldTimezoneString.match options.ignore
      return callback null, oldTimezoneString

  if options.conversions?
    if typeof options.conversions is "string"
      _loadConversionFiles options.conversions, (error, conversions) ->
        return callback error if error?
        callback null, _convertTimezoneString conversions, oldTimezoneString
    else if typeof options.conversions is "object"
      callback null,  _convertTimezoneString options.conversions, oldTimezoneString
    else
      callback new Error "Unsupported timezone conversion object"
  else
    callback new Error "No Timezone conversions given"

module.exports = {convert, _convertTimezoneString, _loadConversionFiles, _conversionCache}