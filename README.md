# SwiftyBeaver 

<img src="https://img.shields.io/badge/Platform-iOS%208%2B-blue.svg" alt="Platform iOS8+">
<img src="https://img.shields.io/badge/Platform-Mac%20OS%20X%2010.9%2B-blue.svg" alt="Platform iOS8+">
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Language-Swift%202-orange.svg" alt="Language: Swift 2" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg" alt="Carthage compatible" /></a>
<a href="https://github.com/skreutzberger/SwiftyBeaver/blob/master/License.txt"><img src="http://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat" alt="License: MIT" /></a>


SwiftyBeaver is a **new**, fast & very **lightweight** logger, with a unique combination of great features. 

It is written in Swift 2 and was released on November 28, 2015 by Sebastian Kreutzberger (Twitter: [@skreutzb](https://twitter.com/skreutzb)).

## Features

1. Log to Xcode Console and / or **log to a file**
3. Add **custom log destination** handlers to log to Loggly, Redis, etc.
1. **Colored output** to Xcode Console(!), log file, etc.
1. Uses **own serial background queues/threads** for a great performance
1. Log levels which are below the set minimum are not executed for even better release performance
2. Easy & convenient configuration
2. Use multiple logging destinations & settings, even for the same type
1. Already comes with good defaults
1. Use `log.debug("foo")` syntax
1. Get started with 3 lines of code
1. Simple installation via Carthage or copy & paste of a single source file
1. Has just ~350 lines of source code, easy to understand

## Colors!

Before we start, 2 screenshots of colored example output.

#### Xcode Console

<img src="https://cloud.githubusercontent.com/assets/564725/11452558/17fd5f04-95ec-11e5-96d2-427f62ed4f05.jpg" width="709">

#### Terminal.app

While tailing the log file.

<img src="https://cloud.githubusercontent.com/assets/564725/11452560/33225d16-95ec-11e5-8461-78f50b9e8da7.jpg" width="672">

***Looks good, tell me more!***

<br><br>



## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7

## Installation

#### via Carthage

You can use [Carthage](https://github.com/Carthage/Carthage
) to install SwiftyBeaver by adding that to your Cartfile: 
```
github "skreutzberger/SwiftyBeaver"
```

#### or Manually
Just drag & drop the file `SwiftyBeaver.swift` from Github into your project. 


## Usage

### Let's go!

Add that near the top of your `AppDelegate.swift` to be able to use SwiftyBeaver in your whole project.

```Swift
import SwiftyBeaver
let log = SwiftyBeaver.self

```

At the the beginning of your `AppDelegate:didFinishLaunchingWithOptions()` add the SwiftyBeaver log destinations (console, file, etc.) and then you can already do the following log level calls globally (**colors included**):
```Swift
// add log destinations. at least one is needed!
let console = ConsoleDestination()  // log to Xcode Console
let file = FileDestination()  // log to default swiftybeaver.log file
log.addDestination(console)
log.addDestination(file)

// Now let’s log!
log.debug("something to debug")  // prio 2, DEBUG in blue
log.info("a nice information")   // prio 3, INFO in green
log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
log.error("ouch, an error did occur!")  // prio 5, ERROR in red
```


## Destination Properties / Options

You can log to Xcode Console, to one or multiple files and to other, custom log destinations. Each log destination is an instance of a Destination class with iths own set of properties with defaults. But most properties / options are the same.

The options should be set before or directly after the `.addDestination(...)` call.


### Console Destination

To log to Xcode Console just instantiate `ConsoleDestination()`, optionally adjust properties and then add the instance to SwiftyBeaver itself.


Property  | Default | Description
------------- | ------------- | -------------
**.detailOutput**  | true | Logs date, file, function, line, level, message.  If set to `false` then just date, level, message are logged.
**.colored**  | true | Colored output or not
**.minLevel**  | SwiftyBeaver.Level.Verbose | Any level with a priority lower than that level is not logged. Possible values are SwiftyBeaver.Level.Verbose, .Debug, .Info .Warning, .Error
**.dateFormat**  | "yyyy-MM-dd HH:mm:ss.SSS" | Logs current date and time including milliseconds

Example:

```Swift
let console = ConsoleDestination() // get new console destination
console.detailOutput = false // log simple (date, level, message)
console.dateFormat = "HH:mm:ss"  // simpler date format
log.addDestination(console) // add to SwiftyBeaver to use destination

```


### File Destination

SwiftyBeaver can write logs to a file by instantiating and adding of `FileDestination()` class. Logging in a different format to multiple files is possible if several file destination instances are created and added. If a file is not existing then it is created. 


Property  | Default | Description
------------- | ------------- | -------------
**.detailOutput**  | true | Logs date, file, function, line, level, message. If set to `false` then just date, level, message are logged.
**.colored**  | true | Colored output or not
**.minLevel**  | SwiftyBeaver.Level.Verbose | Any level with a priority lower than that level is not logged. Possible values are SwiftyBeaver.Level.Verbose, .Debug, .Info .Warning, .Error
**.dateFormat**  | "yyyy-MM-dd HH:mm:ss.SSS" | Logs current date and time including milliseconds
**.logFileURL**  | DocumentDirectory + "swiftybeaver.log" | The default filename is `swiftybeaver.log` and it is stored in the app’s DocumentDirectory. During development it is recommended to change that logfileURL to `/tmp/swiftybeaver.log` so that the file can be tailed by a Terminal app using the CLI command `tail -f /tmp/swiftybeaver.log`.

Example with logging to 2 files in parallel:

```Swift
let file = FileDestination() // get new file destination instance
// uses standard logging to swiftybeaver.log
file.detailOutput = false
file.colored = true
file.minLevel = Level.Verbose
file.dateFormat = "HH:mm:ss.SSS"
log.addDestination(file) // add to SwiftyBeaver to use destination

// the second file with different properties and custom filename
let file2 = FileDestination()
file.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
file2.minLevel = Level.Info
file2.logFileURL = NSURL(string: "file:///tmp/app_info.log")!
log.addDestination(file2)
```

## Own Logging Destinations

It is very easy to write own custom logging destinations, for example to Loggly, Logstash, Redis, Postgres, because all log formatting and preparation logic is already done in SwiftyBeaver.swift and BaseDestination.swift for you!

All logging destination classes need to subclass `BaseDestination()` and just need to override the `send()` method. By calling `super.send(...)` you already receive the finally formatted log string which can then be edited or directly sent / stored at any other system, storage or server.

To get started, please check the destination classes [ConsoleDestination.swift](https://github.com/skreutzberger/SwiftyBeaver/blob/master/SwiftyBeaver/Destinations/ConsoleDestination.swift) and [FileDestination.swift](https://github.com/skreutzberger/SwiftyBeaver/blob/master/SwiftyBeaver/Destinations/FileDestination.swift) which do the logging to Xcode Console and File. 

If you wrote some great new destinations then **please contribute them**!


## No Colors?!
If Xcode does not show the log level word in color and you activated that option then you still may need the additional  [Xcode-Colors](https://github.com/robbiehanson/XcodeColors) plugin. 

Simple installation of the plugin:

1. Download the file [XcodeColors.xcplugin.zip](https://github.com/skreutzberger/SwiftyBeaver/raw/master/Assets/XcodeColors.xcplugin.zip)
2. Unzip it to "~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
3. Restart Xcode & allow the plugin

Now it should work. If not then please create an issue.


## Contact & Contribute
If you have questions please contact me via Twitter [@skreutzb](https://twitter.com/skreutzb). Feature requests or bugs are better reported and discussed as Github Issue.

**Please contribute back** any great stuff, especially logging destinations and ways to make SwiftyBeaver even more flexible, elegant and awesome!

Thanks for testing, sharing, staring & contributing - Happy Logging!

## License
SwiftyBeaver is released under the [MIT License](https://github.com/skreutzberger/SwiftyBeaver/blob/master/License.txt).

