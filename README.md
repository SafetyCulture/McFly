# McFly
Converts obsolete IANA/Olsen timezone strings into modern IANA Timezone Database strings.

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

## Purpose and Intent

McFly provides a convenient mechanism to modernise obsolete Olsen/IANA timezone strings into their modern equivalent.
  It is specifically designed to ingest 'link' files provided by IANA as part of their Timezone Database which are
  used to alias one timezone string to another timezone string.

### Default conversions

McFly, by default, utilises the 'backward' database, part of the larger IANA Timezone Database which is available
  under a Public Domain license. This will convert all deprecated timezone strings which have at any time formed a part
  of the IANA or Olsen Timezone Databases to their modern equivalent.

Included 'Backward' Version: **2015b**

#### Limitations

* McFly only converts timezone strings known to conform to a given format which have a valid current equivalent. The IANA
    Timezone Database maintains a list of known historical, obsolete and obscure Timezones which are not covered by the
    database. Timezone representations which have never formed part of the IANA or Olsen databases are also unsupported.

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

```
mcFly.convert("Asia/Saigon", function(error, result){
    \\ Output Asia/Ho_Chi_Minh
    console.log(result);
})
```

#### Using custom options

```
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
```

## Caveats

* When using conversions loaded from a file these are cached in-memory for the lifetime of the module's life in memory.
    This means changes to the state of conversions of the filesystem may not be updated unless the module is re-imported
    or the `_conversionCache` property on the module root is cleared.