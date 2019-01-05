
                         __---~~~~--__                      __--~~~~---__
                        `\---~~~~~~~~\\                    //~~~~~~~~---/'
                          \/~~~~~~~~~\||                  ||/~~~~~~~~~\/
                                      `\\                //'
                                        `\\            //'
                                          ||          ||      Hey Doc!
                                ______--~~~~~~~~~~~~~~~~~~--______
                           ___ // _-~                        ~-_ \\ ___
                          `\__)\/~                              ~\/(__/'
                           _--`-___                            ___-'--_
                         /~     `\ ~~~~~~~~------------~~~~~~~~ /'     ~\
                        /|        `\         ________         /'        |\
                       | `\   ______`\_      \------/      _/'______   /' |
                       |   `\_~-_____\ ~-________________-~ /_____-~_/'   |
                       `.     ~-__________________________________-~     .'
                        `.      [_______/------|~~|------\_______]      .'
                         `\--___((____)(________\/________)(____))___--/'
                          |>>>>>>||                            ||<<<<<<|
                          `\<<<<</'                            `\>>>>>/'

# McFly

[![Build Status](https://travis-ci.org/SafetyCulture/McFly.svg?branch=master)](https://travis-ci.org/SafetyCulture/McFly)
[![Coverage Status](https://coveralls.io/repos/github/SafetyCulture/McFly/badge.svg?branch=master)](https://coveralls.io/github/SafetyCulture/McFly?branch=master)

## Purpose and Intent

McFly provides a convenient mechanism to modernise obsolete or deprecated Olson/IANA timezone strings into their 
modern equivalent timezone string. 

Example:
`Asia/Saigon` -> `Asia/Ho_Chi_Minh`
  
## Installation

Install via NPM

    npm install mcfly-timezone
    
### Conversions

McFly, by default, utilises the 'backward' database, part of the larger IANA Timezone Database which is available
  under a Public Domain license. This will convert all deprecated timezone strings which have at any time formed a part
  of the IANA or Olson Timezone Databases to their modern equivalent.
  
Included 'Backward' Version: **2018i**
  
McFly is designed to ingest 'link' files provided by IANA as part of their Timezone Database which are
  used to alias one timezone string to another timezone string. You can provide other link files from the IANA data 
  files using the custom configuration options below. 

## Usage

Require the McFly module and call the `convert` method passing in the `oldTimezoneString`, a set of `options` (optional)
  and a `callback` to be called on completion. If the given timezone string has a valid conversion it will be converted
  to the new format, if not the original string will be returned.

### Arguments

* `oldTimezoneString` - A timezone string to be converted
* `options` - A set of options to configure the conversion of timezone strings (optional). See below for the available
  options. If not given the default options will be used.
* `callback` - A callback which is called when the conversion is complete

#### Options

* `conversions` - A file or directory path to the IANA TZ DB Link file/files OR an object where keys are deprecated
    timezone strings where the value corresponds to their linked target string. Default: `"<module path>/conversions"`
* `ignore` - A regular expression defining any old timezone strings which should be ignored for conversion. Default:
    `null`

### Example

#### Using default options

    mcFly.convert("Asia/Saigon", function(error, result){
        \\ Output Asia/Ho_Chi_Minh
        console.log(result);
    })

#### Using custom options


    options = {
        conversions: {
            'Europe/Belfast': 'Europe/London',
            'GB': 'Europe/London',
            'GB-Eire': 'Europe/London'
        },
        ignore: /\//
    }
    
    mcFly.convert("Europe/Belfast", options, function(error, result){
        \\ Output Europe/Belfast
        console.log(result);
    })
    
    mcFly.convert("GB", options, function(error, result){
        \\ Output Europe/London
        console.log(result);
    })
    
#### Limitations

* McFly only converts timezone strings known to conform to a given format which have a valid current equivalent. The IANA
    Timezone Database maintains a list of known historical, obsolete and obscure Timezones which are not covered by the
    database. Timezone representations which have never formed part of the IANA or Olson databases are also unsupported.

## Caveats

* When using conversions loaded from a file these are cached in-memory for the lifetime of the module's life in memory.
    This means changes to the state of conversions of the filesystem may not be updated unless the module is re-imported
    or the `_conversionCache` property on the module root is cleared.
    

