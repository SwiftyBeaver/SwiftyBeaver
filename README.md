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
1. **Colored output** to Xcode Console
1. Colored output to log file (tail with terminal apps)
1. Runs on an **own serial background queue/thread** for a great performance
1. Log levels which are below the set minimum are not executed for even better release performance
1. Easy & convenient configuration with a struct
1. Already comes with good defaults
1. optionally use `log.debug("foo")` instead of `SwiftyBeaver.debug("foo")`
1. Get started with a single line of code
1. Simple installation via Carthage or copy & paste of a single source file
1. Has just ~300 lines of source code, easy to understand

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

Now you can already do the following log level calls globally (**colors included**):

```Swift
log.verbose("not so important")  // priority 1, output has word "VERBOSE" in silver color
log.debug("something to debug")  // prio 2, DEBUG in blue
log.info("a nice information")   // prio 3, INFO in green
log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
log.error("ouch, an error did occur!")  // prio 5, ERROR in red
```

That’s it :)

## Options

You can log to Xcode Console and / or to a file. Both output channels have an own set of options with defaults. 

The options can be set at any time during the run-time of the app but it is recommended to **set custom options as 
early as possible**, maybe even in `AppDelegate:didFinishLaunchingWithOptions`. 

### Options for Console Logging

Just add one or multiple of the following calls with example option values. For demo purpose the values are the defaults:

```Swift
// log.Options.Console <- a struct which contains the following console logging options:

log.Options.Console.active = true //  Do or do not log to console
log.Options.Console.detailOutput = false  // log simple (date, level, message) 
log.Options.Console.detailOutput = true  // default: detailed (date, file, function, line, level, message)
log.Options.Console.colored = true  // log the level using color
log.Options.Console.minLevel = Level.Verbose  //  any level below that priority is not logged
log.Options.Console.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"  // dateformat including milliseconds
```

### Options for File Logging

SwiftyBeaver can also write logs to a file if activated. If the file is not existing then it is created. 

The default filename is `swiftybeaver.log` and it is stored in the app’s DocumentDirectory. 
During development it is recommended to change that logfileURL to `/tmp/swiftybeaver.log` so that the file can be tailed by a Terminal app using the CLI command `tail -f /tmp/swiftybeaver.log`.


```Swift
// log.Options.File <- a struct which contains the following file logging options:

log.Options.File.active = false //  Do or do not log to file. Deactivated on default!!!
log.Options.File.detailOutput = false  // log simple (date, level, message) 
log.Options.File.detailOutput = true  // default: detailed (date, file, function, line, level, message)
log.Options.File.colored = true  // log the level using color
log.Options.File.minLevel = Level.Verbose  //  any level below that priority is not logged
log.Options.File.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"  // dateformat including milliseconds
log.Options.File.logFileURL = documentsURL.URLByAppendingPathComponent("swiftybeaver.log", isDirectory: false)
```

## No Colors?!
If Xcode does not show the log level word in color and you activated that option then you still may need the additional  [Xcode-Colors](https://github.com/robbiehanson/XcodeColors) plugin. 

Simple installation of the plugin:

1. Download the file [XcodeColors.xcplugin.zip](https://github.com/skreutzberger/SwiftyBeaver/raw/master/Assets/XcodeColors.xcplugin.zip)
2. Unzip it to "~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/"
3. Restart Xcode & allow the plugin

Now it should work. If not then please create an issue.

## Contact & Contribute
If you have questions please contact me via Twitter [@skreutzb](https://twitter.com/skreutzb). Feature requests or bugs are better reported and discussed as Github Issue.

Thanks for testing, sharing, staring & contributing - Happy Logging!

## License
SwiftyBeaver is released under the [MIT License](https://github.com/skreutzberger/SwiftyBeaver/blob/master/License.txt).

