//
//  AppDelegate.swift
//  SBExampleApp
//
//  Created by Gregory Hutchinson on 5/6/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import UIKit
import SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let log = SwiftyBeaver.self
        let consoleDestination = ConsoleDestination()
        log.addDestination(consoleDestination)

        let platformDestination = SBPlatformDestination(appID: Secrets.Platform.appID, appSecret: Secrets.Platform.appSecret, encryptionKey: Secrets.Platform.encryptionKey)
        log.addDestination(platformDestination)

        let fileDestination = FileDestination()
        log.addDestination(fileDestination)

        log.setupCrashReporter()

        return true
    }
}

