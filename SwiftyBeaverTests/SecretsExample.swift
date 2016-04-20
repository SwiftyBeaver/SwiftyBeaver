//
//  SecretsExample.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 1/25/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

/*
    WARNING:
    ========

    Never put this file with values under source control!

    Instead copy & rename this file to Secrets.swift (!!!), uncomment the Secrets struct
    and add your credentials there. Secrets.swift is excluded from Git via .gitignore and can contain secrets.

*/


struct Secrets {

    struct Platform {
        static let appID = ""
        static let appSecret = ""
        static let encryptionKey = ""
    }
}
