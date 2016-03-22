# Change Log

All notable changes to this project will be documented in this file following the style described at [Keep a Changelog](http://keepachangelog.com) by [@olivierlacan](https://github.com/olivierlacan). 
This project adheres to [Semantic Versioning](http://semver.org/).

----

## Next Version 

#### Added 
- <add text here during development>

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



