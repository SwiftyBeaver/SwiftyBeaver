<p align="center"><img src="https://cloud.githubusercontent.com/assets/564725/13137893/1b8eced2-d624-11e5-9264-3416ff821657.png" width="280" alt="SwiftyBeaver"><br/><b>Colorful</b>, extensible, <b>lightweight</b> logging for Swift 2 & 3.<br/>Great for <b>development & release</b> with support for Console, File & cloud platforms.<br/>NEW: Log <b>during release</b> to the conveniently built-in SwiftyBeaver Platform and Mac App!<br/><br/>

<a href="http://docs.swiftybeaver.com">Docs</a> |
<a href="https://swiftybeaver.com">Website</a> |
<a href="https://slack.swiftybeaver.com">Slack</a> |
<a href="https://twitter.com/SwiftyBeaver">Twitter</a> | 
<a href="https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/LICENSE">License</a>
<br/>
</p>

<p align="center">
[![Language Swift 2 & 3](https://img.shields.io/badge/Language-Swift%202%20&%203-orange.svg)](https://developer.apple.com/swift) [![Travis Build Status](https://travis-ci.org/SwiftyBeaver/SwiftyBeaver.svg?branch=master)](https://travis-ci.org/SwiftyBeaver/SwiftyBeaver) [![Slack Status](https://slack.swiftybeaver.com/badge.svg)](https://slack.swiftybeaver.com) 
<br/>
<p>
----

<br/>

### During Development: Colored Logging to Xcode Console

<img src="https://cloud.githubusercontent.com/assets/564725/14951113/ea682b42-1056-11e6-824f-a6da82e2a0a8.png" width="637">

[Learn more](http://docs.swiftybeaver.com/article/9-log-to-xcode-console) about colored logging to Xcode Console.

<br/>

### During Development: Colored Logging to File

<img src="https://cloud.githubusercontent.com/assets/564725/14951092/d5948f44-1056-11e6-9f6e-81801a130661.png" width="659">

[Learn more](http://docs.swiftybeaver.com/article/10-log-to-file) about logging to file.

<br/>


### On Release: Encrypted Logging to SwiftyBeaver Platform

<img src="https://cloud.githubusercontent.com/assets/564725/14281408/38d6a6ba-fb39-11e5-9584-34e3679bb1c5.jpg" width="700">

[Learn more](http://docs.swiftybeaver.com/article/11-log-to-swiftybeaver-platform) about logging to the SwiftyBeaver Platform during release.

<br/>


### Browse, Search & Filter via Mac App

![swiftybeaver-demo1](https://cloud.githubusercontent.com/assets/564725/14846071/218c0646-0c62-11e6-92cb-e6e963b68724.gif)

Conveniently access your logs during development & release with our [free Mac App](https://swiftybeaver.com).

<br/>


## Installation

You can use [Carthage](https://github.com/Carthage/Carthage) to install SwiftyBeaver by adding that to your Cartfile:

``` 
github "SwiftyBeaver/SwiftyBeaver"
```

#### via CocoaPods

To use [CocoaPods](https://cocoapods.org) just add this to your Podfile:

``` Ruby
pod 'SwiftyBeaver'
```

#### via Swift Package Manager (Swift 2.2)

To use SwiftyBeaver as a [Swift Package Manager](https://swift.org/package-manager/) package just add the following in your Package.swift file.

``` Swift
import PackageDescription

let package = Package(
  name: "HelloWorld",
  dependencies: [
    .Package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", majorVersion: 0)
  ]
)
```

<br/>


## Usage

Add that near the top of your `AppDelegate.swift` to be able to use SwiftyBeaver in your whole project.

``` Swift
import SwiftyBeaver

let log = SwiftyBeaver.self

```

At the the beginning of your `AppDelegate:didFinishLaunchingWithOptions()` add the SwiftyBeaver log destinations (console, file, etc.) and then you can already do the following log level calls globally (**colors included**):

``` Swift
// add log destinations. at least one is needed!
let console = ConsoleDestination()  // log to Xcode Console
let file = FileDestination()  // log to default swiftybeaver.log file
let cloud = SBPlatformDestination(appID: "foo", appSecret: "bar", encryptionKey: "123") // to cloud
log.addDestination(console)
log.addDestination(file)
log.addDestination(cloud)

// Now let’s log!
log.verbose("not so important")  // prio 1, VERBOSE in silver
log.debug("something to debug")  // prio 2, DEBUG in green
log.info("a nice information")   // prio 3, INFO in blue
log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
log.error("ouch, an error did occur!")  // prio 5, ERROR in red

// log anything!
log.verbose(123)
log.info(-123.45678)
log.warning(NSDate())
log.error(["I", "like", "logs!"])
log.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])
```

<br/>

----

## Documentation

**Getting Started:**

- [Features](http://docs.swiftybeaver.com/article/7-introduction)
- [Installation](http://docs.swiftybeaver.com/article/5-installation)
- [Basic Setup](http://docs.swiftybeaver.com/article/6-basic-setup)
​

**Logging Destinations:**

- [Colored Logging to Xcode Console](http://docs.swiftybeaver.com/article/9-log-to-xcode-console)
- [Colored Logging to File](http://docs.swiftybeaver.com/article/10-log-to-file)
- [Encrypted Logging & Analytics to SwiftyBeaver Platform](http://docs.swiftybeaver.com/article/11-log-to-swiftybeaver-platform)



**Stay Informed:**

- [Official Website](https://swiftybeaver.com)
- [Medium Blog](https://medium.com/swiftybeaver-blog)
- [On Twitter](https://twitter.com/SwiftyBeaver)


More destination & system documentation is coming soon! <br/>Get support via Github Issues, email and <a href="https://slack.swiftybeaver.com">public Slack channel</a>.


<br/>
## License

SwiftyBeaver Framework is released under the [MIT License](https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/LICENSE).
