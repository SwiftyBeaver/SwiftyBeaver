//
//  ConsoleDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation


/**
 Enumerations for types of CustomDestinations

 - UsePrint:                                          use swift 'print'
 - UseNSLog:                                          use NSLog
 - UseCustom:                                         use a custom block to generate a new ConsoleDestination

 */
public enum ConsoleDestinationType {
    public typealias CustomBlockType = ((Any...) -> ())


    case UsePrint
    case UseNSLog
    case UseCustom(CustomBlockType)


    /**
     useDebugPrintWithTarget

     - parameter target:     Target you wish to use. Type must satisify OutputStreamType
     - parameter separator:  String - seperator to use
     - parameter terminator: String terminator to use

     - returns: .ConsoleDestinationType

        using the same separator and terminator defaults found here :
     https://github.com/apple/swift/blob/master/stdlib/public/core/Print.swift
     */
    static func usePrintWithTarget<Target: OutputStreamType>(inout target: Target,
                                                               separator: String = " ",
                                                              terminator: String = "/n") -> ConsoleDestinationType {


        let customBlock: CustomBlockType = { (str: Any...) in
            print(str, separator: separator, terminator: terminator, toStream: &target)

        }
        return .UseCustom(customBlock)

    }

    func printToConsole(str: String) {
        switch self {
        case .UsePrint:
            print(str)
        case .UseNSLog:
            NSLog(str)
        case let .UseCustom(custom):
            custom(str)
        }
    }

}

public class ConsoleDestination: BaseDestination {
    
    @available(*, deprecated=0.0, message="use the var consoleType instead!")
    public var useNSLog : Bool  {
        get {
            switch consoleType {
            case .UsePrint:
                return false
            case .UseNSLog:
                return true
            case .UseCustom:
                return false
            }
        }
        set(newValue) {
            if case .UseCustom = self.consoleType {
                print("useNSLog is ignored if consoleType is Custom!")
            }
            else if (newValue) {
                self.consoleType = .UseNSLog
            }
            else {
                self.consoleType = .UsePrint
            }
        }
    }

    override public var defaultHashValue: Int {return 1}

    public var consoleType: ConsoleDestinationType = .UsePrint

    public override init() {
        super.init()
    }

    // print to Xcode Console. uses full base class functionality
    override public func send(level: SwiftyBeaver.Level,
                                msg: String,
                             thread: String,
                               path: String,
                           function: String,
                               line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, path: path, function: function, line: line)

        if let str = formattedString {
            consoleType.printToConsole(str)
        }
        return formattedString
    }
}
