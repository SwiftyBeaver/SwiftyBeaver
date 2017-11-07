//
//  DeviceInfo.swift
//  SwiftyBeaver
//
//  Created by Konstantin Klitenik on 8/26/17.
//  Copyright © 2017 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

// platform-dependent import frameworks to get device details
// valid values for os(): OSX, iOS, watchOS, tvOS, Linux
// in Swift 3 the following were added: FreeBSD, Windows, Android
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
var DEVICE_MODEL: String {
    get {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
#else
let DEVICE_MODEL = ""
#endif

#if os(iOS) || os(tvOS)
var DEVICE_NAME = UIDevice.current.name
#else
    // under watchOS UIDevice is not existing, http://apple.co/26ch5J1
let DEVICE_NAME = ""
#endif
