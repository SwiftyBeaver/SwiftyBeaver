//
//  Extensions.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 13.12.17.
//  Copyright © 2017 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

extension String {
    /// cross-Swift compatible characters count
    var length: Int {
        #if swift(>=3.2)
            return self.count
        #else
            return self.characters.count
        #endif
    }
    
    /// cross-Swift-compatible first character
    var firstChar: Character? {
        #if swift(>=3.2)
            return self.first
        #else
            return self.characters.first
        #endif
    }
    
    /// cross-Swift-compatible last character
    var lastChar: Character? {
        #if swift(>=3.2)
            return self.last
        #else
            return self.characters.last
        #endif
    }
    
    /// cross-Swift-compatible index
    func find(_ char: Character) ->  Index? {
        #if swift(>=3.2)
            return self.index(of: char)
        #else
            return self.characters.index(of: char)
        #endif
    }
}

