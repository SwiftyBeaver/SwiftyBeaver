# SwiftyBeaver

<img src="https://img.shields.io/badge/Platform-iOS%208%2B-blue.svg" alt="Platform iOS8+">
<img src="https://img.shields.io/badge/Platform-Mac%20OS%20X%2010.9%2B-blue.svg" alt="Platform iOS8+"> <img src="https://img.shields.io/badge/tvOS-9%2B-blue.svg" alt="Platform tvOS8+"> <img src="https://img.shields.io/badge/watchOS-2%2B-blue.svg" alt="Platform tvOS8+"><br/>
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Language-Swift%202-orange.svg" alt="Language: Swift 2" /></a>
<a href="https://github.com/apple/swift-package-manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="Swift Package Manager compatible" /></a> <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg" alt="Carthage compatible" /></a>
<a href="https://cocoapods.org"><img src="https://img.shields.io/cocoapods/v/SwiftyBeaver.svg" alt="Cocoapods compatible" /></a>
<a href="https://github.com/skreutzberger/SwiftyBeaver/blob/master/LICENSE"><img src="http://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat" alt="License: MIT" /></a>


SwiftyBeaver is a **colorful**, fast, flexible & very **lightweight** logger, with a unique combination of great features.

It is written in Swift 2, supports Swift Package Manager and was released on November 28, 2015 by [Sebastian Kreutzberger](https://twitter.com/skreutzb). 

It is under active development, so please **follow [SwiftyBeaver on Twitter](https://twitter.com/SwiftyBeaver)** to stay up-to-date on new versions & features or to get in contact.

## Features

1. Log to Xcode Console and / or **log to a file**
3. Add **custom log destination** handlers to log to Loggly, Redis, etc.
1. **Colored output** to Xcode Console(!), log file, etc.
1. Uses **own serial background queues/threads** for a great performance
1. Log levels which are below the set minimum are not executed for even better release performance
2. **Increases productivity & saves a lot of time** thanks to "Needle in the Haystack" mode
2. Easy & convenient configuration
2. Use multiple logging destinations & settings, even for the same type
1. Already comes with good defaults
1. Use `log.debug("foo")` syntax
1. Get started with 3 lines of code
1. Simple installation via Carthage, CocoaPods, Swift Package Manager or download
1. Has just ~350 lines of source code, easy to understand
2. Native support for leading Xcode development plugins

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

#### Platform & Installation Support


\ | iOS 8+ | OSX 10.9+ | watchOS 2+ | tvOS 9+
------------- | ------------- | ------------- | ------------- | -------------
[Swift Package Manager](https://swift.org/package-manager/) | <center>✅</center> | <center>✅</center> | <center>✅</center> | <center>✅</center>  
[Carthage](https://github.com/Carthage/Carthage) | <center>✅</center> | <center>✅</center> | <center>✅</center> | <center>✅</center>  
[CocoaPods](https://cocoapods.org) | <center>✅</center> | <center>✅</center> | <center>✅</center> | <center>✅</center>  
Download | <center>✅</center> | <center>✅</center> | <center>✅</center> | <center>✅</center>  

For installation details please see the next points.

#### via Carthage

You can use [Carthage](https://github.com/Carthage/Carthage
) to install SwiftyBeaver by adding that to your Cartfile:
```
github "skreutzberger/SwiftyBeaver"
```

#### via CocoaPods

To use [CocoaPods](https://cocoapods.org) just add this to your Podfile:
```
pod 'SwiftyBeaver', '~> 0.2'
```

#### via Swift Package Manager (Swift 2.2 beta)

To use SwiftyBeaver as a [Swift Package Manager](https://swift.org/package-manager/) package just add the following in your Package.swift file.

```Swift
import PackageDescription

let package = Package(
    name: "HellowWorld",
    dependencies: [
        .Package(url: "https://github.com/skreutzberger/SwiftyBeaver.git", majorVersion: 0)]),
    ]
)
```

#### or Download
1. Download the latest release zip from [here](https://github.com/skreutzberger/SwiftyBeaver/releases)
2. Drag & drop the `/sources` folder into your project (make sure "Copy items if needed" is checked)
3. Rename the "sources" group to "SwiftyBeaver" if you'd like

Note: You don't have to `import SwiftyBeaver` if you install this way.

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

// log anything!
log.verbose(123)
log.info(-123.45678)
log.warning(NSDate())
log.error(["I", "like", "logs!"])
log.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])
```


## Destination Properties

You can log to Xcode Console, to one or multiple files and to other, custom log destinations. Each log destination is an instance of a Destination class with it’s own set of properties with defaults.

The properties should be set before or directly after the `.addDestination(...)` call. Please see some examples further down below.

###  Core Properties

The following core properties are **available for every destination** and must be **set individually** for every destination instance!


Property  | Default | Description
------------- | ------------- | -------------
**.detailOutput**  | true | Logs date, file, function, line, level, message.  If set to `false` then just date, level, message are logged.
**.colored**  | true | Colored output or not
**.minLevel**  | SwiftyBeaver.Level.Verbose | Any level with a priority lower than that level is not logged. Possible values are SwiftyBeaver.Level.Verbose, .Debug, .Info .Warning, .Error. Use `.addMinLevelFilter()` to find the needle in the haystack (see further below).
**.dateFormat**  | "yyyy-MM-dd HH:mm:ss.SSS" | Logs current date and time including milliseconds. If you set an empty String then no date is added to the log.
**.levelString.Verbose, .Debug, .Info, .Warning, .Error**  | "VERBOSE", "DEBUG", etc. | Sets a custom string representing the log level. On default it is the log level as uppercase word.


### Log to Console

To log to Xcode Console just instantiate `ConsoleDestination()`, optionally adjust properties and then add the instance to SwiftyBeaver itself.

Example:

```Swift
let console = ConsoleDestination() // get new console destination
console.detailOutput = false // log simple (date, level, message)
console.dateFormat = "HH:mm:ss"  // simpler date format
log.addDestination(console) // add to SwiftyBeaver to use destination

```


### Log to File

SwiftyBeaver can write logs to a file by instantiating and adding of the `FileDestination()` class. Logging in a different format to multiple files is possible if several file destination instances are created and added. If a file is not existing then it is created.

Additional to above mentioned core properties the file destination also comes with the following properties:

Property  | Default | Description
------------- | ------------- | -------------
**.logFileURL**  | DocumentDirectory+"swiftybeaver.log" | The default filename is `swiftybeaver.log` and it is stored in the app’s DocumentDirectory. During development it is recommended to change that logfileURL to `/tmp/swiftybeaver.log` so that the file can be tailed by a Terminal app using the CLI command `tail -f /tmp/swiftybeaver.log`.

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
file2.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
file2.minLevel = Level.Info
file2.levelString.Error = "Beaver Alarm!"
file2.logFileURL = NSURL(string: "file:///tmp/app_info.log")!
log.addDestination(file2)
```

## Own Logging Destinations

It is very easy to write own custom logging destinations, for example to Loggly, Logstash, Redis, Postgres, because all log formatting and preparation logic is already done in SwiftyBeaver.swift and BaseDestination.swift for you!

All logging destination classes need to subclass `BaseDestination()` and just need to override the `send()` method. By calling `super.send(...)` you already receive the finally formatted log string which can then be edited or directly sent / stored at any other system, storage or server.

To get started, please check the destination classes [ConsoleDestination.swift](https://github.com/skreutzberger/SwiftyBeaver/blob/master/SwiftyBeaver/Destinations/ConsoleDestination.swift) and [FileDestination.swift](https://github.com/skreutzberger/SwiftyBeaver/blob/master/SwiftyBeaver/Destinations/FileDestination.swift) which do the logging to Xcode Console and File.

If you wrote some great new destinations then **please contribute them**!


## The Needle in the Haystack

<img src="https://cloud.githubusercontent.com/assets/564725/11744328/b0f45b9a-a00f-11e5-813a-23de809cb456.jpg"/>

After a while every software project is full of `log.verbose()` or `log.debug()`statements. Fixing a small bug in the middle of the application logic often requires reading and parsing of hundreds of log messages until you find the message you are really interested in.

This really annoying issue could until now just be fixed by commenting out all unnecessary `log.verbose()` or `log.debug()` lines in the module or whole software - a tedious, time-consuming task just to focus on a bug in a single file or function.

But SwiftyBeaver comes with **a much better solution** called MinLevelFilters.

A MinLevelFilter **overrules the minimum log level** of the destination for a certain file or folder name pattern and a function or function name pattern. SwiftyBeaver’s MinLevelFilters are so flexible that you can add multiple filters per destination and the filter pattern themselve are very easy to understand and can have a **huge positive impact on your productivity** during development and debugging.


### How to add a MinLevelFilter

Let's assume the following every-day-work example: you have a grown project, it is full of `log.verbose()` and `log.debug()`. You currently work on the the file `MyViewController.swift` and you are just interested in the `log.verbose()` lines of the file. So what do you need to do?

Firstly, set the general minimum log level for the whole app to `.Info`:

```Swift
let console = ConsoleDestination()
console.minLevel = .Info
```

Secondly, add a MinLevelFilter which sets the MinLevel for the file `MyViewController.swift` to `.Verbose`.

```Swift
console.addMinLevelFilter(.Verbose, path: "MyViewController.swift")
```

Now when you run your app you will just see logging output of level `.Info` and higher and **additionally all** logging output from `MyViewController.swift` due to the minLevelFilter `.Verbose` of the file.


### MinLevelFilters Are Very Flexible

Internally SwiftyBeaver checks on every log event if the absolute path of the source file and the function name of the log statement do match the filter arguments. 

The matching itself is done by checking if the strings do either match or the source strings contain the filter strings. 

The matching is **case-sensitive** and for path it compares the **absolute path**.

Let’s take an example for better understanding:

```Swift
let console = ConsoleDestination()
console.minLevel = .Info // just log if .Info or higher if not filter matches

// some path examples with matching pattern
var path = "MyViewController.swift" // matches *MyViewController.swift*
path = "MyViewController" // matches *MyViewController*
path = "ViewController" // matches *MyViewController*
path = "MyLib/" // matches *MyLib/*

console.addMinLevelFilter(.Verbose, path: path)
```

And an example to match all function names  which contain the word `init` in files which have the word `ViewController` in their absolute path:

```Swift
var path = "ViewController" // pattern *ViewController*
var function = "init" // function pattern *init*
console.addMinLevelFilter(.Verbose, path: path, function: function)
```

That's great, isn’t it? And also please keep in mind that **a destination can have multiple MinLevelFilters**. 

And finally a complete and complex example which sets the minLevel all files in the folder `MyLib` to `.Debug`, and the minLevel all function names inside and outside everywhere in the app containing the word `setup` to `.Verbose`:

```Swift
let c = ConsoleDestination()
c.minLevel = .Info // just log if .Info or higher

console.addMinLevelFilter(.Verbose, path: "MyLib/")
console.addMinLevelFilter(.Debug, path: "", "setup")

log.addDestination(console)
```

## No Colors?!
If Xcode does not show the log level word in color and you activated that option then you still may need the additional  [Xcode-Colors](https://github.com/robbiehanson/XcodeColors) plugin.

Simple installation of the plugin:

1. Download the file [XcodeColors.xcplugin.zip](https://github.com/skreutzberger/SwiftyBeaver/raw/master/Assets/XcodeColors.xcplugin.zip)
2. Unzip it to "~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/" (if this directory path does not exist, you can just create it)
3. Restart Xcode & allow the plugin

Now it should work. If not then please create an issue.

## Clickable Hyperlink to Source in Console

SwiftyBeaver supports Krzysztof Zabłocki’s great Xcode Plugin [KZLinkedConsole](https://github.com/krzysztofzablocki/KZLinkedConsole) which adds a clickable link to each line that is logged in Xcode Console. The link leads to the file and line of the log message and is a great helper during Console debugging!

Simple installation of the plugin:

1. Download the file [KZLinkedConsole.xcplugin.zip](https://github.com/skreutzberger/SwiftyBeaver/raw/master/Assets/KZLinkedConsole.xcplugin.zip)
2. Unzip it to "~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/" (if this directory path does not exist, you can just create it)
3. Restart Xcode & allow the plugin


## Contact & Contribute
If you have questions please contact Sebastian via the dedicated [SwiftyBeaver Twitter account](https://twitter.com/SwiftyBeaver). Feature requests or bugs are better reported and discussed as Github Issue.

**Please contribute back** any great stuff, especially logging destinations and ways to make SwiftyBeaver even more flexible, elegant and awesome! Each new bugfix, feature request or addition/change should be put in **a dedicated pull request** to simplify discussion and merging.

Thanks for testing, sharing, staring & contributing - Happy Logging!

## License
SwiftyBeaver is released under the [MIT License](https://github.com/skreutzberger/SwiftyBeaver/blob/master/LICENSE).

