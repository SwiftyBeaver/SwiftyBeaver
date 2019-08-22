# Change Log

All notable changes to this project will be documented in this file following the style described at [Keep a Changelog](http://keepachangelog.com) by [@olivierlacan](https://github.com/olivierlacan). 
This project adheres to [Semantic Versioning](http://semver.org/).

----
<br/>

## 1.7.1 (2019-08-22)

##### Added
- Improved file destination by [@CognitiveDisson](https://github.com/CognitiveDisson)
- Improved README by [@skreutzberger](https://github.com/skreutzberger)
- All build targets can use Swift 5 by [@DivineDominion](https://github.com/DivineDominion)


##### Fixed
- Issue in BaseDestination with non-required filters by [@FelixII ](https://github.com/FelixII)


<br/>

## 1.7.0 (2019-03-26)

##### Added

- Support for Swift 5 and Xcode 10.2 by [@lgaches](https://github.com/lgaches)
- Support for CircleCI 2.0 by [@lgaches](https://github.com/lgaches)


<br/>

## 1.6.2 (2019-02-11)

##### Added

- Improved SPM support for Swift 4.2 by [@heyzooi ](https://github.com/heyzooi)
- Improved Carthage support for Swift 4.2 by [@iachievedit ](https://github.com/iachievedit)
- Swift type inference by [@rafalmq ](https://github.com/rafalmq)


<br/>

## 1.6.1 (2018-09-18)

##### Added

- Optional sync after each file write by [@crspybits ](https://github.com/crspybits)
- Execute methods to run in dest queue by [@keeshux ](https://github.com/keeshux)
- Padded format option (see [PR for details](https://github.com/SwiftyBeaver/SwiftyBeaver/pull/298)) by [@htb ](https://github.com/htb)


##### Fixed
- Warning caused by iOS 12 by [@lgaches](https://github.com/lgaches)
- Issues with formating by [@htb ](https://github.com/htb)

<br/>

## 1.6.0 (2018-05-23)

##### Added

- Custom filters by [@Mordil ](https://github.com/Mordil )
- App uptime format variable `$U` by [@LordNali ](https://github.com/LordNali )

##### Changed
- Filter behavior which requires now at least one passing non-required filter by [@cconway](https://github.com/cconway)

<br/>

## 1.5.2 (2018-04-05)

##### Added

- Support for Xcode 9.3 and Swift 4.1 by [@jimmya](https://github.com/jimmya)

<br/>

## 1.5.1 (2018-01-05)

##### Added

- Integration test for context format variable `$X` by [@skreutzberger](https://github.com/skreutzberger)
- Logging output string is trimmed by [@skreutzberger](https://github.com/skreutzberger)

##### Fixed

- Fixed issue with Xcode and folder name on case-sensitive file systems by [@konstantinbe](https://github.com/konstantinbe)


<br/>

## 1.5.0 (2017-12-13)

##### Added

- Cross-compatibility for Swift 3.1, 3.2 & 4 by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.4.4 (2017-12-08)

##### Added

- Set a custom server URL already on platform destination init by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.4.3 (2017-11-09)

##### Added

- Support for latest Xcode 9.1 by removing deprecation warning by [@tomekh7](https://github.com/tomekh7)
- Reduced the overall size of the framework by [@NachoSoto](https://github.com/NachoSoto)
- Improved support for Swift 4 via SPM by [@lgaches](https://github.com/lgaches)

<br/>

## 1.4.2 (2017-09-26)

##### Fixed

- Fixed memory leak in SBPlatformDestination by [@drougojrom](https://github.com/drougojrom)

<br/>

## 1.4.1 (2017-09-18)

##### Fixed

- Disabled code coverage to fix app submission with Xcode 9 by [@NachoSoto](https://github.com/NachoSoto)

<br/>

## 1.4.0 (2017-08-12)

##### Added

- Support for latest Xcode 9 beta, Swift 3.2 & Swift 4 by [@lgaches](https://github.com/lgaches)
- Less aggressive file protection type when logfile is created by [@igorefremov](https://github.com/igorefremov)

<br/>

## 1.3.2 (2017-07-19)

##### Fixed

- Issue under macOS server-side Swift with file protection type by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.3.1 (2017-07-19)

##### Added
- Better solution to instable b64 encoding of Swift 3.1.x under Linux  by [@lgaches](https://github.com/lgaches)
- Set file protection type when logfile is created by [@igorefremov](https://github.com/igorefremov)

<br/>

##### Fixed

- Issue with validation of required filters by [@alessandroorru](https://github.com/alessandroorru)
- Issue issue with multiple destinations with message filters by [@alessandroorru](https://github.com/alessandroorru)

<br/>

## 1.3.0 (2017-06-22)

##### Added

- New context parameter for more detailed logging by [@lgaches](https://github.com/lgaches)
- Support for more watchOS versions by [@basememara](https://github.com/basememara)

<br/>

## 1.2.2 (2017-05-04)

##### Fixed

- Issue while building for macOS, tvOS & watchOS by [@alex-can](https://github.com/alex-chan)
- Issue while building on a case-sensitive file system by [@alex-can](https://github.com/alex-chan)

<br/>

## 1.2.1 (2017-04-24)

##### Fixed

- Logic issue in filter by [@rajatk](https://github.com/rajatk)

<br/>

## 1.2.0 (2017-04-11)

##### Added

- Google Cloud / Stackdriver destination by [@lgaches](https://github.com/lgaches)

<br/>

## 1.1.4 (2017-03-28)

##### Added

- console destination property `.useTerminalColors` by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.1.3 (2017-02-22)

##### Added

- Output logging object as JSON with `.format = "$J"` by [@skreutzberger](https://github.com/skreutzberger)
- Adjust internal filenames in SBPlatform destination by [@skreutzberger](https://github.com/skreutzberger)

##### Changed

- a filter’s `required` parameter is now also working for levels by [@picciano](https://github.com/picciano)


##### Removed

- The option to turn just the message into JSON with `.format = "$m"` by [@skreutzberger](https://github.com/skreutzberger)


<br/>

## 1.1.2 (2017-02-16)

##### Added

- Support for Swift 3.1 by [@skreutzberger](https://github.com/skreutzberger)
- Use of official Swift Docker images by [@skreutzberger](https://github.com/skreutzberger)
- Method `deleteLogFile()` to manually delete log file by [@felipowsky](https://github.com/felipowsky)
- Explicit deployment target for tvOS by [@Dschee](https://github.com/Dschee)

##### Changed

- `Public` is now `Open` in `SwiftyBeaver.swift` by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.1.1 (2016-10-28)

##### Added

- Support for Xcode 8.1 by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.1.0 (2016-10-12)

##### Added

- Support for server-side Swift (macOS & Linux) by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.0.3 (2016-09-21)

##### Changed

- New format key `$Z` outputs datetime as UTC by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.0.2 (2016-09-19)

##### Changed

- Lowercase enum cases (`.Debug` -> `.debug`) to match Swift 3 convention by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.0.1 (2016-09-17)

##### Added

- Colored log level indicators for Xcode 8 Console by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 1.0.0 (2016-09-15)

##### Added

- Support for Xcode 8 & Swift 3 by [@skreutzberger](https://github.com/skreutzberger)

##### Changed

- Master branch is written in Swift 3 instead of Swift 2 by [@skreutzberger](https://github.com/skreutzberger)
- Names of platform destination support files are public by [@skreutzberger](https://github.com/skreutzberger)
- Default format has colored log level after time by [@skreutzberger](https://github.com/skreutzberger)
- README explains installation under Swift 2 and Swift 3 by [@skreutzberger](https://github.com/skreutzberger)

##### Removed

- swift3 branch & tag 0.0.0 by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.7.0 (2016-09-09)

##### Added

- Exclusion filter by [@renaun](https://github.com/renaun)
- Custom log formatting by [@skreutzberger](https://github.com/skreutzberger)

##### Removed

- .detailOutput, .colored & .coloredLines properties by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.6.5 (2016-07-29)

##### Changed

- On Xcode 8 colored console output is disabled by [@skreutzberger](https://github.com/skreutzberger)

##### Fixed

- Broken support for tvOS in platform destination by [@markj](https://github.com/markj)

<br/>

## 0.6.4 (2016-07-28)

##### Added

- Support for use in app extensions by [@madhavajay](https://github.com/madhavajay)

##### Changed

- Minimum target for OS X is 10.10 by [@DivineDominion](https://github.com/DivineDominion)

##### Fixed

- Potential issue when setting a platform sending threshold of lower than 1 by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.6.3 (2016-06-29)

##### Added

- Filters can have their own minimum log level by [@skreutzberger](https://github.com/skreutzberger)
- Prepared for new macOS alias for OS detection by [@skreutzberger](https://github.com/skreutzberger)

##### Removed

- Dedicated log level filter by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.6.2 (2016-06-21)

##### Added

- Support for Swift 2.3 under Xcode 8 beta by [@brentleyjones](https://github.com/brentleyjones)

##### Fixed

- Potential crash when using ConsoleDestination with NSLog by [@nickoto](https://github.com/nickoto)

##### Removed

- Deprecated MinLevelFilter functionality by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.6.1 (2016-06-08)

##### Changed

- Filter `required` argument defines AND (`required: true`) or OR (`required: false`) relation between filters by [@JeffBNimble](https://github.com/JeffBNimble)

<br/>

## 0.6.0 (2016-06-07)

##### Added

- New filter system for level, path, function, message per destination by [@JeffBNimble](https://github.com/JeffBNimble)

##### Changed

- `.minLevel` & `minLevelFilter()` are deprecated. Use the new filter system instead by [@JeffBNimble](https://github.com/JeffBNimble)

<br/>
## 0.5.4 (2016-05-20)

##### Changed

- Function names are now logged without parameters (inspired by Gábor Sajó) by [@skreutzberger](https://github.com/skreutzberger)
- Default location of log file and other internally used files by [@skreutzberger](https://github.com/skreutzberger)

##### Fixed

- Memory leak in string manipulation by [@dkalachov](https://github.com/dkalachov)

<br/>

## 0.5.3 (2016-05-11)

##### Added

- Ability to adjust destination properties during runtime by [@MarkQSchultz](https://github.com/MarkQSchultz)

##### Changed

- Message resolution is done in background for better performance by [@JeffBNimble](https://github.com/JeffBNimble)
- Lowered minimum OSX version to 10.10 for CocoaPods by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.5.2 (2016-05-02)

##### Added

- Get more colored content with `coloredLines = true` by [@DasHutch](https://github.com/DasHutch)

##### Changed

- Adjusted Xcode Console colors to match SwiftyBeaver Mac App UI by [@DasHutch](https://github.com/DasHutch)
- Adjusted file destination colors to match SwiftyBeaver Mac App UI by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.5.1 (2016-04-28)

##### Added

- Type-safe adding/removal of destination by [@muukii](https://github.com/muukii)
- Allow empty log messages by [@ewanmellor](https://github.com/ewanmellor)
- Console can use NSLog instead of print by [@skreutzberger](https://github.com/skreutzberger)
- Exposing of framework version & build for easier support by [@skreutzberger](https://github.com/skreutzberger)

##### Fixed
- Issue with overwritten analytics data by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.5.0 (2016-04-19)

##### Added

- SwiftyBeaver Platform destination by [@skreutzberger](https://github.com/skreutzberger)
- SwiftyBeaver AES256CBC class for string encryption by [@skreutzberger](https://github.com/skreutzberger)
- Lots of small improvements by [@skreutzberger](https://github.com/skreutzberger)

<br/>
## 0.4.2 (2016-03-22)

##### Changed

- Optimized codebase for Swift 2.2, Swift 3 & Xcode 7.3 by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.4.1 (2016-03-11)

##### Added

- Option to log synchronously during development by [@muukii](https://github.com/muukii)
- Code completion docs for most public variables & functions by [@skreutzberger](https://github.com/skreutzberger)
- Internal linting of code base by [@skreutzberger](https://github.com/skreutzberger)

<br/>

## 0.4.0 (2016-03-04)

##### Added

- Default log file directory is OS-dependent by [@xeo-it](https://github.com/xeo-it)
- Flush function is accessible to all destinations by [@prenagha](https://github.com/prenagha)
- Customizable log colors by [@fvvliet](https://github.com/fvvliet)

##### Changed

- Default log file directory for iOS, tvOS & watchOS is an app’s cache directory by [@xeo-it](https://github.com/xeo-it)

<br/><br/>

## 0.3.5 (2016-02-24)

##### Changed

- Optimized performance by letting log functions take @autoclosure by [@reesemclean](https://github.com/reesemclean)

<br/>

## 0.3.4 (2016-02-23)

##### Changed

- Optimized writing to log file by [@skreutzberger](https://github.com/skreutzberger). Thanks go to [Andy Chou](https://twitter.com/_achou) for pointing on it.

<br/>

## 0.3.3 (2016-02-09)

##### Added

- `Flush` function to make sure all logging messages have been written out by [@prenagha](https://github.com/prenagha)

##### Changed

- Versions & tags do not start with a "v" anymore by [@skreutzberger](https://github.com/skreutzberger)


<br/>

## 0.3.2 (2016-02-04)

##### Added

- Easier creation of custom destinations by making certain base class functions public by [@irace](https://github.com/irace)
- Secrets.* files are ignored by Git to act as credential-holding file in the future by [@skreutzberger](https://github.com/skreutzberger)


<br/>

## 0.3.1 (2016-01-11)

##### Added

- Logging of thread by [@VDKA](https://github.com/VDKA)



<br/>

## 0.3.0 (2015-12-11)

#### Added

- File-based minimum level filters by [@skreutzberger](https://github.com/skreutzberger)



<br/><br/>

## 0.2.5 (2015-12-10)

#### Added

- Support for KZLinkedConsole plugin by [@skreutzberger](https://github.com/skreutzberger)
- Installation via Carthage for tvOS, watchOS & OSX by [@davidrothera](https://github.com/davidrothera)
- Introduction of API limitation to allowed SwiftyBeaver to be used in Extensions by [@impossibleventures](https://github.com/impossibleventures)


<br/>

## 0.2.4 (2015-12-09)

#### Added

- Installation via Cocoapods for tvOS, watchOS2 & OSX by [@davidrothera](https://github.com/davidrothera)

#### Changed

- No date output if date format is empty by [@skreutzberger](https://github.com/skreutzberger)


<br/>

## 0.2.3 (2015-12-09)

#### Added

- Installation via Swift Package Manager by [@davidrothera](https://github.com/davidrothera)


<br/>

## 0.2.2 (2015-12-09)

#### Added

- Installation via Cocoapods by [@davidrothera](https://github.com/davidrothera)

#### Fixed

- Wrong level word displayed for Debug level by [@skreutzberger](https://github.com/skreutzberger)


<br/>

## 0.2.1 (2015-12-06)

#### Added

- Flexible level names by [@skreutzberger](https://github.com/skreutzberger)
- Logging of all types and not just strings by [@skreutzberger](https://github.com/skreutzberger)


<br/>

## 0.2.0 (2015-12-05)

#### Added

- Dedicated serial queues for each destination by [@skreutzberger](https://github.com/skreutzberger)
- Destinations are now each in a single file by [@skreutzberger](https://github.com/skreutzberger)

#### Fixed

- Wrong scope of `init`function by [@skreutzberger](https://github.com/skreutzberger)


<br/>
## 0.1.1 (2015-12-01)

#### Added

- Downloadable assets by [@skreutzberger](https://github.com/skreutzberger)

#### Fixed

- Deployment version to make Carthage work by [@manuelvanrijn](https://github.com/manuelvanrijn)
- License text by [@skreutzberger](https://github.com/skreutzberger)


<br/>

## 0.1.0 (2015-11-28)

#### Added

- Initial release by [@skreutzberger](https://github.com/skreutzberger)


