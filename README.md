<p align="center"><b>Colorful</b>, flexible, <b>lightweight</b> logging for Swift 3, Swift 4 & <b>Swift 5</b>.<br/>Great for <b>development & release</b> with support for Console, file & cloud destinations for server-side Swift.</p>

<p align="center"><a href="https://swift.org" target="_blank"><img src="https://img.shields.io/badge/Language-Swift%203,%204%20&%205-orange.svg" alt="Language Swift 2, 3, 4 & 5"></a> <a href="https://circleci.com/gh/SwiftyBeaver/SwiftyBeaver" target="_blank"><img src="https://circleci.com/gh/SwiftyBeaver/SwiftyBeaver/tree/master.svg?style=shield" alt="CircleCI"/></a><br/><p>

---

<br/>

### During Development: Colored Logging to Xcode Console

<img src="https://cloud.githubusercontent.com/assets/564725/18608323/ac065a98-7ce6-11e6-8e1b-2a062d54a1d5.png" width="608">

[Learn more](http://docs.swiftybeaver.com/article/9-log-to-xcode-console) about colored logging to Xcode 8 Console with Swift 3, 4 & 5. For Swift 2.3 [use this Gist](https://gist.github.com/skreutzberger/7c396573796473ed1be2c6d15cafed34). **No need to hack Xcode 8 anymore** to get color. You can even customize the log level word (ATTENTION instead of ERROR maybe?), the general amount of displayed data and if you want to use the 💜s or replace them with something else 😉

<br/>

### During Development: Colored Logging to File

<img src="https://cloud.githubusercontent.com/assets/564725/18608325/b7ecd4c2-7ce6-11e6-829b-7f8f9fe6ef2f.png" width="738">

[Learn more](http://docs.swiftybeaver.com/article/10-log-to-file) about logging to file which is great for Terminal.app fans or to store logs on disk.

<br/>

### Google Cloud & More

You can fully customize your log format, turn it into JSON, or create your own destinations. For example, our [Google Cloud Destination](https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/Sources/GoogleCloudDestination.swift) is just another customized logging format that adds the powerful functionality of automatic server-side Swift logging when hosted on Google Cloud Platform.

<br/>

---

<br/>
<br/>

## Installation

- For **Swift 4 & 5** install the latest SwiftyBeaver version
- For **Swift 3** install SwiftyBeaver 1.8.4
- For **Swift 2** install SwiftyBeaver 0.7.0

<br/>

### Carthage

You can use [Carthage](https://github.com/Carthage/Carthage) to install SwiftyBeaver by adding that to your Cartfile:

Swift 4 & 5:

```Swift
github "SwiftyBeaver/SwiftyBeaver"
```

Swift 3:

```Swift
github "SwiftyBeaver/SwiftyBeaver" ~> 1.8.4
```

Swift 2:

```Swift
github "SwiftyBeaver/SwiftyBeaver" ~> 0.7
```

<br/>

### Swift Package Manager

For [Swift Package Manager](https://swift.org/package-manager/) add the following package to your Package.swift file. Just Swift 4 & 5 are supported:

```Swift
.package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.0.0")),
```

<br/>

### CocoaPods

To use [CocoaPods](https://cocoapods.org) just add this to your Podfile:

Swift 4 & 5:

```Swift
pod 'SwiftyBeaver'
```

Swift 3:

```Ruby
target 'MyProject' do
  use_frameworks!

  # Pods for MyProject
  pod 'SwiftyBeaver', '~> 1.8.4'
end
```

Swift 2:

```Ruby
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
<br/>

## Usage

Add that near the top of your `AppDelegate.swift` to be able to use SwiftyBeaver in your whole project.

```Swift
import SwiftyBeaver
let log = SwiftyBeaver.self

```

At the beginning of your `AppDelegate:didFinishLaunchingWithOptions()` add the SwiftyBeaver log destinations (console, file, etc.), optionally adjust the [log format](http://docs.swiftybeaver.com/article/20-custom-format) and then you can already do the following log level calls globally:

```Swift
// add log destinations. at least one is needed!
let console = ConsoleDestination()  // log to Xcode Console
let file = FileDestination()  // log to default swiftybeaver.log file

// use custom format and set console output to short time, log level & message
console.format = "$DHH:mm:ss$d $L $M"
// or use this for JSON output: console.format = "$J"

// add the destinations to SwiftyBeaver
log.addDestination(console)
log.addDestination(file)

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

// optionally add context to a log message
console.format = "$L: $M $X"
log.debug("age", context: 123)  // "DEBUG: age 123"
log.info("my data", context: [1, "a", 2]) // "INFO: my data [1, \"a\", 2]"

```

Alternatively, if you are using SwiftUI, consider using the following setup:

```swift
import SwiftyBeaver
let logger = SwiftyBeaver.self

@main
struct yourApp: App {

    init() {
        let console = ConsoleDestination()
        logger.addDestination(console)
        // etc...
    }

    var body: some Scene {
        WindowGroup {
        }
    }
}
```

<br/>
<br/>

## Server-side Swift

We ❤️ server-side Swift 4 & 5 and SwiftyBeaver support it **out-of-the-box**! Try for yourself and run SwiftyBeaver inside a Ubuntu Docker container. Just install Docker and then go to your project folder on macOS or Ubuntu and type:

```shell
# create docker image, build SwiftyBeaver and run unit tests
docker run --rm -it -v $PWD:/app swiftybeaver /bin/bash -c "cd /app ; swift build ; swift test"

# optionally log into container to run Swift CLI and do more stuff
docker run --rm -it --privileged=true -v $PWD:/app swiftybeaver
```

Best: for the popular server-side Swift web framework [Vapor](https://github.com/vapor/vapor) you can use **[our Vapor logging provider](https://github.com/SwiftyBeaver/SwiftyBeaver-Vapor)** which makes server logging awesome again 🙌

<br/>
<br/>

## Documentation

**Getting Started:**

- [Features](http://docs.swiftybeaver.com/article/7-introduction)
- [Installation](http://docs.swiftybeaver.com/article/5-installation)
- [Basic Setup](http://docs.swiftybeaver.com/article/6-basic-setup)

**Logging Destinations:**

- [Colored Logging to Xcode Console](http://docs.swiftybeaver.com/article/9-log-to-xcode-console)
- [Colored Logging to File](http://docs.swiftybeaver.com/article/10-log-to-file)

**Advanced Topics:**

- [Custom Format & Context](http://docs.swiftybeaver.com/article/20-custom-format)
- [Filters](http://docs.swiftybeaver.com/article/21-filters)

<br/>
<br/>

## License

SwiftyBeaver Framework is released under the [MIT License](https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/LICENSE).
