<p align="center"><a href="https://swiftybeaver.com"><img src="https://cloud.githubusercontent.com/assets/564725/19889302/73b1ee84-a034-11e6-8753-2d060502397c.jpg" style="width: 888px;" alt="SwiftyBeaver"></a><br/><b>Colorful</b>, flexible, <b>lightweight</b> logging for Swift 2, Swift 3 & <b>Swift 4</b>.<br/>Great for <b>development & release</b> with support for Console, File & cloud platforms.<br/>Log <b>during release</b> to the conveniently built-in SwiftyBeaver Platform, the <b>dedicated Mac App</b> & <b>Elasticsearch</b>!<br/><br/><a href="http://docs.swiftybeaver.com">Docs</a> | <a href="https://swiftybeaver.com">Website</a> | <a href="https://slack.swiftybeaver.com">Slack</a> | <a href="https://twitter.com/SwiftyBeaver">Twitter</a> | <a href="https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/LICENSE">License</a><br/></p>

<p align="center"><a href="https://swift.org" target="_blank"><img src="https://img.shields.io/badge/Language-Swift%202,%203%20&%204-orange.svg" alt="Language Swift 3 & 4"></a> <a href="https://circleci.com/gh/SwiftyBeaver/SwiftyBeaver" target="_blank"><img src="https://circleci.com/gh/SwiftyBeaver/SwiftyBeaver/tree/master.svg?style=shield" alt="CircleCI"/></a> <a href="https://slack.swiftybeaver.com" target="_blank"><img src="https://img.shields.io/badge/Join-Our%20Slack%20Chat-blue.svg" alt="Slack Status"/></a><br/><p>

----

<br/>

### During Development: Colored Logging to Xcode Console

<img src="https://cloud.githubusercontent.com/assets/564725/18608323/ac065a98-7ce6-11e6-8e1b-2a062d54a1d5.png" width="608">

[Learn more](http://docs.swiftybeaver.com/article/9-log-to-xcode-console) about colored logging to Xcode 8 Console with Swift 3 & 4. For Swift 2.3 [use this Gist](https://gist.github.com/skreutzberger/7c396573796473ed1be2c6d15cafed34). **No need to hack Xcode 8 anymore** to get color. You can even customize the log level word (ATTENTION instead of ERROR maybe?), the general amount of displayed data and if you want to use the 💜s or replace them with something else 😉

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

<br/>


### On Release: Enterprise-ready Logging to Your Elasticsearch & Kibana (on-premise)

<img src="https://user-images.githubusercontent.com/564725/34486363-dc501aec-efcf-11e7-92b2-1163cca9e7aa.jpg" width="700">

[Learn more](http://docs.swiftybeaver.com/article/34-enterprise-quick-start-via-docker) about **legally compliant**, end-to-end encrypted logging to Elasticsearch with **SwiftyBeaver Enterprise**. Install via Docker or manual, fully-featured free trial included!

<br/>

### Google Cloud & More

You can fully customize your log format, turn it into JSON, or create your own destinations. For example our [Google Cloud Destination](https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/Sources/GoogleCloudDestination.swift) is just another customized logging format which adds the powerful functionality of automatic server-side Swift logging when hosted on Google Cloud Platform.

<br/>

----

<br/>
<br/>

## Installation

- For **Swift 3 & 4** install the latest SwiftyBeaver version
- For **Swift 2** install SwiftyBeaver 0.7.0

<br/>

### Carthage

You can use [Carthage](https://github.com/Carthage/Carthage) to install SwiftyBeaver by adding that to your Cartfile:

Swift 3 & 4:
``` Swift
github "SwiftyBeaver/SwiftyBeaver"
```

Swift 2:
``` Swift
github "SwiftyBeaver/SwiftyBeaver" ~> 0.7
```

<br/>

### Swift Package Manager

For [Swift Package Manager](https://swift.org/package-manager/) add the following package to your Package.swift file. Just Swift 3 & 4 are supported:

``` Swift
.Package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", majorVersion: 1)
```

<br/>

### CocoaPods

We plan to discontinue the support for CocoaPods due to its issues with latest Xcode and Swift versions latest at the end of 2018. Please use Carthage or SPM instead to stay on top of new SwiftyBeaver releases.

To use [CocoaPods](https://cocoapods.org) just add this to your Podfile:

Swift 3 & 4:
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
// or use this for JSON output: console.format = "$J"

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

## Server-side Swift

We ❤️ server-side Swift 3 & 4 and SwiftyBeaver supports it **out-of-the-box**! Try for yourself and run SwiftyBeaver inside a Ubuntu Docker container. Just install Docker and then go to your the project folder on macOS or Ubuntu and type:

```shell
# create docker image, build SwiftyBeaver and run unit tests
swift build --clean && docker build --rm -t swiftybeaver .

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
- [Encrypted Logging & Analytics to SwiftyBeaver Platform](http://docs.swiftybeaver.com/article/11-log-to-swiftybeaver-platform)
- [Encrypted Logging & Analytics to Elasticsearch & Kibana](http://docs.swiftybeaver.com/article/34-enterprise-quick-start-via-docker)


**Advanced Topics:**

- [Custom Format](http://docs.swiftybeaver.com/article/20-custom-format)
- [Filters](http://docs.swiftybeaver.com/article/21-filters)

**Stay Informed:**

- [Official Website](https://swiftybeaver.com)
- [Medium Blog](https://medium.com/swiftybeaver-blog)
- [On Twitter](https://twitter.com/SwiftyBeaver)


More destination & system documentation is coming soon! <br/>Get support via Github Issues, email and <a href="https://slack.swiftybeaver.com">public Slack channel</a>.


<br/>
<br/>

## License

SwiftyBeaver Framework is released under the [MIT License](https://github.com/SwiftyBeaver/SwiftyBeaver/blob/master/LICENSE).
