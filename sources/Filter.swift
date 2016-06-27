//
//  Filter.swift
//  SwiftyBeaver
//
//  Created by Jeff Roberts on 5/31/16.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

/// FilterType is a protocol that describes something that determines
/// whether or not a message gets logged. A filter answers a Bool when it
/// is applied to a value. If the filter passes, it shall return true,
/// false otherwise.
///
/// A filter must contain a target, which identifies what it filters against
/// A filter can be required meaning that all required filters against a specific
/// target must pass in order for the message to be logged. At least one non-required
/// filter must pass in order for the message to be logged
public protocol FilterType : class {
    func apply(value: AnyObject) -> Bool
    func getTarget() -> Filter.TargetType
    func isRequired() -> Bool
    func reachedMinLevel(level: SwiftyBeaver.Level) -> Bool
}

/// Filters is syntactic sugar used to easily construct filters
public class Filters {
    public static let Path = PathFilterFactory.self
    public static let Function = FunctionFilterFactory.self
    public static let Message = MessageFilterFactory.self
}

/// Filter is an abstract base class for other filters
public class Filter {
    public enum TargetType {
        case Path(Filter.ComparisonType)
        case Function(Filter.ComparisonType)
        case Message(Filter.ComparisonType)
    }

    public enum ComparisonType {
        case StartsWith([String], Bool)
        case Contains([String], Bool)
        case EndsWith([String], Bool)
        case Equals([String], Bool)
    }

    let targetType: Filter.TargetType
    let required: Bool
    let minLevel: SwiftyBeaver.Level

    public init(target: Filter.TargetType, required: Bool, minLevel: SwiftyBeaver.Level) {
        self.targetType = target
        self.required = required
        self.minLevel = minLevel
    }

    public func getTarget() -> Filter.TargetType {
        return self.targetType
    }

    public func isRequired() -> Bool {
        return self.required
    }

    /// returns true of set minLevel is >= as given level
    public func reachedMinLevel(level: SwiftyBeaver.Level) -> Bool {
        //print("checking if given level \(level) >= \(minLevel)")
        return level.rawValue >= minLevel.rawValue
    }
}

/// CompareFilter is a FilterType that can filter based upon whether a target
/// starts with, contains or ends with a specific string. CompareFilters can be
/// case sensitive.
public class CompareFilter: Filter, FilterType {
    override public init(target: Filter.TargetType, required: Bool, minLevel: SwiftyBeaver.Level) {
        super.init(target: target, required: required, minLevel: minLevel)
    }

    public func apply(value: AnyObject) -> Bool {
        guard let value = value as? String else {
            return false
        }

        let comparisonType: Filter.ComparisonType?
        switch self.getTarget() {
        case let .Function(comparison):
            comparisonType = comparison

        case let .Path(comparison):
            comparisonType = comparison

        case let .Message(comparison):
            comparisonType = comparison

        /*default:
            comparisonType = nil*/
        }

        guard let filterComparisonType = comparisonType else {
            return false
        }

        let matches: Bool
        switch filterComparisonType {
            case let .Contains(strings, caseSensitive):
                matches = !strings.filter {
                    string in
                    return caseSensitive ? value.containsString(string) :
                        value.lowercaseString.containsString(string.lowercaseString)
                }.isEmpty


            case let .StartsWith(strings, caseSensitive):
                matches = !strings.filter {
                    string in
                    return caseSensitive ? value.hasPrefix(string) :
                        value.lowercaseString.hasPrefix(string.lowercaseString)
                }.isEmpty

            case let .EndsWith(strings, caseSensitive):
                matches = !strings.filter {
                    string in
                    return caseSensitive ? value.hasSuffix(string) :
                        value.lowercaseString.hasSuffix(string.lowercaseString)
                }.isEmpty

            case let .Equals(strings, caseSensitive):
                matches = !strings.filter {
                    string in
                    return caseSensitive ? value == string :
                        value.lowercaseString == string.lowercaseString
                }.isEmpty
        }

        return matches
    }
}

// Syntactic sugar for creating a function comparison filter
public class FunctionFilterFactory {
    public static func startsWith(prefixes: String..., caseSensitive: Bool = false,
                                  required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Function(.StartsWith(prefixes, caseSensitive)),
                             required: required, minLevel: minLevel)
    }

    public static func contains(strings: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Function(.Contains(strings, caseSensitive)),
                             required: required, minLevel: minLevel)
    }

    public static func endsWith(suffixes: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Function(.EndsWith(suffixes, caseSensitive)),
                             required: required, minLevel: minLevel)
    }

    public static func equals(strings: String..., caseSensitive: Bool = false,
                              required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Function(.Equals(strings, caseSensitive)),
                             required: required, minLevel: minLevel)
    }
}

// Syntactic sugar for creating a message comparison filter
public class MessageFilterFactory {
    public static func startsWith(prefixes: String..., caseSensitive: Bool = false,
                                  required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Message(.StartsWith(prefixes, caseSensitive)),
                             required: required, minLevel: minLevel)
    }

    public static func contains(strings: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Message(.Contains(strings, caseSensitive)),
                             required: required, minLevel: minLevel)
    }

    public static func endsWith(suffixes: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Message(.EndsWith(suffixes, caseSensitive)),
                             required: required, minLevel: minLevel)
    }

    public static func equals(strings: String..., caseSensitive: Bool = false,
                              required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Message(.Equals(strings, caseSensitive)),
                             required: required, minLevel: minLevel)
    }
}

// Syntactic sugar for creating a path comparison filter
public class PathFilterFactory {
    public static func startsWith(prefixes: String..., caseSensitive: Bool = false,
                                  required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Path(.StartsWith(prefixes, caseSensitive)),
                             required: required, minLevel: minLevel)
    }

    public static func contains(strings: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Path(.Contains(strings, caseSensitive)),
                             required: required, minLevel: minLevel)
    }

    public static func endsWith(suffixes: String..., caseSensitive: Bool = false,
                                required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Path(.EndsWith(suffixes, caseSensitive)),
                             required: required, minLevel: minLevel)
    }

    public static func equals(strings: String..., caseSensitive: Bool = false,
                              required: Bool = false, minLevel: SwiftyBeaver.Level = .Verbose) -> FilterType {
        return CompareFilter(target: .Path(.Equals(strings, caseSensitive)),
                             required: required, minLevel: minLevel)
    }
}

extension Filter.TargetType : Equatable {
}

// The == does not compare associated values for each enum. Instead == evaluates to true
// if both enums are the same "types", ignoring the associated values of each enum
public func == (lhs: Filter.TargetType, rhs: Filter.TargetType) -> Bool {
    switch (lhs, rhs) {

    case (.Path(_), .Path(_)):
        return true

    case (.Function(_), .Function(_)):
        return true

    case (.Message(_), .Message(_)):
        return true

    default:
        return false
    }
}
