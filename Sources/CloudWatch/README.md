# SwiftyBeaver/CloudWatch

SwiftyBeaver/CloudWatch cocoapods subspec creates a SwiftyBeaver log destination for AWS Cloudwatch.

###NOTE: AWS CloudWatch cocoapod dependencies do *not* support tvos, watchos, or macos at this time.
### This POD subspec currently *only* supports iOS and only Cocoapods package manager.

## Installation

Swift 4 & 5 (Cocoapods):
``` Swift
pod 'SwiftyBeaver/CloudWatch'
```

Note that other Swift package managers are not supported for this subspec.

##Usage

To create a log destination for AWS Cloudwatch on iOS you must use the included class wrappers to authenticate to AWS using  Cognito Identity pool, and either create a log stream or use a log stream which is already created in your AWS account.

While there are a few ways to do this, the wrapper currently supports unauthenticated Cognito Identity Pool access.  See AWS documentation on how to use Cognito Identity Pools and how to setup your IAM role for the identity pool properly to access CloudWatch resources.

Here is an example of setting up the SwiftyBeaver destination for AWS CloudWatch.

``` Swift

//Note that since a log stream is being created asynchronously, no logging should occur in the app until
//the completion block is invoked.

func initializeLog(completion: @escaping () -> Void) {
    let serviceConfig = AWSServiceConfig(cognitoPoolId: "somePoolId", regionType: .USWest1).create()
    let cloudWatchLogs = CloudWatchLogs(config: serviceConfig, clientKey: "someClientKey")
    let group = CloudWatchLogGroup(name: "/my/log/group/name")
    let cloudWatchStream = CloudWatchLogStream(cloudWatchLogs: cloudWatchLogs, group: cloudWatchLogGroup, name: "/my/Log/stream/name")

    cloudWatchLogStream.create() { error in
        //add the SwiftyBeaver log destinations.. (log has been setup as in the SwiftyBeaver docs)
        self.log.addDestination(ConsoleDestination())
        self.log.addDestination(AWSCloudWatchDestination(logStream: cloudWatchLogStream))
        DispatchQueue.main.async {
            completion()
        }
    }
}

```

