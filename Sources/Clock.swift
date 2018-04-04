//
//  Created by Christian Tietze (@ctietze) on 2017-12-14.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import struct Foundation.Date

public protocol Clock {
    func now() -> Date
}

public struct SystemClock: Clock {
    public init() { }

    public func now() -> Date {
        return Date()
    }
}
