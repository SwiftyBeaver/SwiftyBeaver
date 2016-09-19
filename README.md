<p align="center"><img src="https://cloud.githubusercontent.com/assets/564725/13137893/1b8eced2-d624-11e5-9264-3416ff821657.png" width="280" alt="SwiftyBeaver"><br/><b>Colorful</b>, flexible, <b>lightweight</b> logging for Swift 2 & <b>Swift 3</b>.<br/>Great for <b>development & release</b> with support for Console, File & cloud platforms.<br/>NEW: Log <b>during release</b> to the conveniently built-in SwiftyBeaver Platform and Mac App!<br/><br/>

<a href="http://docs.swiftybeaver.com">Docs</a> |
<a href="https://swiftybeaver.com">Website</a> |
<a href="https://slack.swiftybeaver.com">Slack</a> |
<a href="https://twitter.com/SwiftyBeaver">Twitter</a> | 
<a href="https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/LICENSE">License</a>
<br/>
</p>

<p align="center">
[![Language Swift 3](https://img.shields.io/badge/Language-Swift%202%20&%203-orange.svg)](https://swift.org) [![Travis Build Status](https://travis-ci.org/SwiftyBeaver/SwiftyBeaver.svg)](https://travis-ci.org/SwiftyBeaver/SwiftyBeaver) [![Slack Status](https://slack.swiftybeaver.com/badge.svg)](https://slack.swiftybeaver.com) 
<br/>
<p>
----

<br/>

### During Development: Colored Logging to Xcode Console

<img src="https://cloud.githubusercontent.com/assets/564725/18608323/ac065a98-7ce6-11e6-8e1b-2a062d54a1d5.png" width="608">

[Learn more](http://docs.swiftybeaver.com/article/9-log-to-xcode-console) about colored logging to Xcode 8 Console. **No need to hack Xcode 8 anymore** to get color. You can even customize the log level word (ATTENTION instead of ERROR maybe?), the general amount of displayed data and if you want to use the 💜s or replace them with something else 😉

<br/>

### During Development: Colored Logging to File

<img src="https://cloud.githubusercontent.com/assets/564725/18608325/b7ecd4c2-7ce6-11e6-829b-7f8f9fe6ef2f.png" width="738">

[Learn more](http://docs.swiftybeaver.com/article/10-log-to-file) about logging to file which is great for Terminal.app fans or to store logs on disk.

<br/>


### On Release: Encrypted Logging to SwiftyBeaver Platform

<img src="https://cloud.githubusercontent.com/assets/564725/14281408/38d6a6ba-fb39-11e5-9584-34e3679bb1c5.jpg" width="700">

[Learn more](http://docs.swiftybeaver.com/article/11-log-to-swiftybeaver-platform) about logging to the SwiftyBeaver Platform **during release!**

<br/>


### Browse, Search & Filter via Mac App

![swiftybeaver-demo1](https://cloud.githubusercontent.com/assets/564725/14846071/218c0646-0c62-11e6-92cb-e6e963b68724.gif)

Conveniently access your logs during development & release with our [free Mac App](https://swiftybeaver.com).

<br/><br/>


## Installation

- For **Swift 3** install the latest SwiftyBeaver version
- For **Swift 2** install SwiftyBeaver 0.7.0

<br/>
### Carthage

You can use [Carthage](https://github.com/Carthage/Carthage) to install SwiftyBeaver by adding that to your Cartfile:

Swift 3:
``` Swift
github "SwiftyBeaver/SwiftyBeaver"
```

Swift 2:
``` Swift
github "SwiftyBeaver/SwiftyBeaver" ~> 0.7
```

<br/>
### CocoaPods

To use [CocoaPods](https://cocoapods.org) just add this to your Podfile:

Swift 3:
``` Swift
pod 'SwiftyBeaver'
```

Swift 2:
``` Ruby
target 'MyProject' do
  use_frameworks!

  # Pods for MyProject
  pod 'SwiftyBeaver', '~> 0.7'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    # Configure Pod targets for Xcode 8 with Swift 2.3
    config.build_settings['SWIFT_VERSION'] = '2.3'
  end
end
```

<br/>
### Swift Package Manager

For [Swift Package Manager](https://swift.org/package-manager/) add the following package to your Package.swift file. Just Swift 3 is supported:

``` Swift
.Package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", majorVersion: 1)
```

<br/>
<br/>


## Usage

Add that near the top of your `AppDelegate.swift` to be able to use SwiftyBeaver in your whole project.

``` Swift
import SwiftyBeaver
let log = SwiftyBeaver.self

```

At the the beginning of your `AppDelegate:didFinishLaunchingWithOptions()` add the SwiftyBeaver log destinations (console, file, etc.), optionally adjust the [log format](http://docs.swiftybeaver.com//article/20-custom-format) and then you can already do the following log level calls globally:

``` Swift
// add log destinations. at least one is needed!
let console = ConsoleDestination()  // log to Xcode Console
let file = FileDestination()  // log to default swiftybeaver.log file
let cloud = SBPlatformDestination(appID: "foo", appSecret: "bar", encryptionKey: "123") // to cloud

// use custom format and set console output to short time, log level & message
console.format = "$DHH:mm:ss$d $L $M"

// add the destinations to SwiftyBeaver
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
log.warning(Date())
log.error(["I", "like", "logs!"])
log.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])
```

<br/>
<br/>

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

**Advanced Topics:**

- [Custom Format](http://docs.swiftybeaver.com/article/20-custom-format)

**Stay Informed:**

- [Official Website](https://swiftybeaver.com)
- [Medium Blog](https://medium.com/swiftybeaver-blog)
- [On Twitter](https://twitter.com/SwiftyBeaver)


More destination & system documentation is coming soon! <br/>Get support via Github Issues, email and <a href="https://slack.swiftybeaver.com">public Slack channel</a>.


<br/>
## License

SwiftyBeaver Framework is released under the [MIT License](https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/LICENSE).
