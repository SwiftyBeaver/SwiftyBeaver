# Change Log

All notable changes to this project will be documented in this file following the style described at [Keep a Changelog](http://keepachangelog.com) by [@olivierlacan](https://github.com/olivierlacan). 
This project adheres to [Semantic Versioning](http://semver.org/).

----
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


