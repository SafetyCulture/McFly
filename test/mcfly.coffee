assert = require 'assert'
path = require 'path'

mcfly = require '../lib/mcfly'

CONVERSION_FILE_PATH = path.join __dirname, "conversions"
CONVERSION_FILE = path.join CONVERSION_FILE_PATH, "test1"

describe 'Conversion', ->

  ###
    convert()
    Given a timezone string and a set of options converts deprecated Olsen Timezone strings to modern equivalents.
  ###

  describe 'convert()', ->

    it 'should convert timezone strings for deprecated strings', (done) ->
      oldTimezoneString = "Deprecated"
      options =
        conversions:
          'Deprecated': "Etc/Modern"

      mcfly.convert oldTimezoneString, options, (error, result) ->
        assert.ifError error
        assert.strictEqual result, "Etc/Modern"
        done()

    it 'should not convert timezone strings for non deprecated strings', (done) ->
      oldTimezoneString = "NotDeprecated"
      options =
        conversions:
          'Deprecated': "Etc/Modern"

      mcfly.convert oldTimezoneString, options, (error, result) ->
        assert.ifError error
        assert.strictEqual result, "NotDeprecated"
        done()

    it 'should not convert timezone strings for deprecated strings that are ignored', (done) ->
      oldTimezoneString = "DeprecatedIgnore"
      options =
        ignore: /(Dep)\w+/
        conversions:
          'DeprecatedIgnore': "Etc/Modern"

      mcfly.convert oldTimezoneString, options, (error, result) ->
        assert.ifError error
        assert.strictEqual result, "DeprecatedIgnore"
        done()

    it 'should convert timezone strings when a conversion file path is given', (done) ->
      oldTimezoneString = "Deprecated4"
      options =
        conversions: CONVERSION_FILE_PATH

      mcfly.convert oldTimezoneString, options, (error, result) ->
        assert.ifError error
        assert.strictEqual result, "Etc/Modern4"
        done()

    it 'should convert timezone strings when a single conversion file is given', (done) ->
      oldTimezoneString = "Deprecated"
      options =
        conversions: CONVERSION_FILE

      mcfly.convert oldTimezoneString, options, (error, result) ->
        assert.ifError error
        assert.strictEqual result, "Etc/Modern"
        done()

    it 'should use the default options when none are provided', (done) ->
      oldTimezoneString = "Egypt"

      mcfly.convert oldTimezoneString, (error, result) ->
        assert.ifError error
        assert.strictEqual result, "Africa/Cairo"
        done()

    it 'should resolve an exception when no conversions are provided', (done) ->
      oldTimezoneString = "Deprecated"
      options = {}

      mcfly.convert oldTimezoneString, options, (error, result) ->
        assert.equal typeof error, "object"
        assert.equal error.toString(), "Error: No Timezone conversions given"
        assert.equal result, undefined
        done()

    it 'should resolve an exception when invalid conversions are provided', (done) ->
      oldTimezoneString = "Deprecated"
      options = {
        conversions: 10
      }

      mcfly.convert oldTimezoneString, options, (error, result) ->
        assert.equal typeof error, "object"
        assert.equal error.toString(), "Error: Unsupported timezone conversion object"
        assert.equal result, undefined
        done()

describe 'Private Methods', ->

  ###
    _convertTimezoneString()
    Given an object of conversions and a timezone string should convert any strings with a valid conversion.
  ###

  describe '_convertTimezoneString()', ->

    it 'should convert timezone strings for keys in the conversions object', ->
      oldTimeZoneString = "Deprecated"
      conversions =
        'Deprecated': "Etc/Modern"

      assert.equal mcfly._convertTimezoneString(conversions, oldTimeZoneString), "Etc/Modern"

    it 'should not convert timezone strings for keys that are not in the conversions object', ->
      oldTimeZoneString = "NotDeprecated"
      conversions =
        'Deprecated': "Etc/Modern"

      assert.equal mcfly._convertTimezoneString(conversions, oldTimeZoneString), "NotDeprecated"

  ###
    _loadConversionFiles()
    Given a timezoneString and a set of options converts deprecated Olsen Timezone strings to modern equivalents.
  ###

  describe '_loadConversionFiles()', ->

    it 'should load a single conversion file into the conversion format', (done) ->
      expected =
        'Deprecated': 'Etc/Modern'
        'Continent/Deprecated2': 'Etc/Modern2'
        'Continent/Country/Deprecated3': 'Etc/Modern3'
        'DeprecatedDoubleTab': 'Etc/ModernDoubleTab'

      mcfly._loadConversionFiles CONVERSION_FILE, (error, result) ->
        assert.deepEqual result, expected
        done()

    it 'should load a conversion path into the conversion format', (done) ->
      expected =
        'Deprecated': 'Etc/ModernDuplicate'
        'Continent/Deprecated2': 'Etc/Modern2'
        'Continent/Country/Deprecated3': 'Etc/Modern3'
        'DeprecatedDoubleTab': 'Etc/ModernDoubleTab'
        'Deprecated4': 'Etc/Modern4'

      mcfly._loadConversionFiles CONVERSION_FILE_PATH, (error, result) ->
        assert.deepEqual result, expected
        done()

    it 'should add loaded conversions to the cache', (done) ->
      expected =
        'Deprecated': 'Etc/ModernDuplicate'
        'Continent/Deprecated2': 'Etc/Modern2'
        'Continent/Country/Deprecated3': 'Etc/Modern3'
        'DeprecatedDoubleTab': 'Etc/ModernDoubleTab'
        'Deprecated4': 'Etc/Modern4'

      mcfly._loadConversionFiles CONVERSION_FILE_PATH, (error, result) ->
        assert.deepEqual mcfly._conversionCache[CONVERSION_FILE_PATH], expected
        done()

    it 'should load from the cache when available', (done) ->
      fakeCacheFile = path.join __dirname, "conversions/cached"
      mcfly._conversionCache[fakeCacheFile] = {
        "CachedDeprecated": "Etc/CachedModern"
      }

      expected = {
        "CachedDeprecated": "Etc/CachedModern"
      }

      mcfly._loadConversionFiles fakeCacheFile, (error, result) ->
        assert.deepEqual result, expected
        done()
