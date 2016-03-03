//
//  Helpers.swift
//  SwiftyBeaver
//
//  Created by Francesco Pretelli on 4/03/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

#if os(iOS)
  let OS = "iOS"
  import UIKit
  let DEVICE_NAME = UIDevice.currentDevice().name
  let DEVICE_MODEL = UIDevice.currentDevice().model
#elseif os(OSX)
  let OS = "OSX"
  let DEVICE_NAME = ""
  let DEVICE_MODEL = ""
#elseif os(watchOS)
  let OS = "watchOS"
  let DEVICE_NAME = ""
  let DEVICE_MODEL = ""
#elseif os(tvOS)
  let OS = "tvOS"
  let DEVICE_NAME = ""
  let DEVICE_MODEL = ""
#elseif os(Linux)
  let OS = "Linux"
  let DEVICE_NAME = ""
  let DEVICE_MODEL = ""
#else
  let OS = "Unknown"
  let DEVICE_NAME = ""
  let DEVICE_MODEL = ""
#endif
