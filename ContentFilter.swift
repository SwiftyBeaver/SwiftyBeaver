//
//  ContentFilter.swift
//  SwiftyBeaver
//
// Created by Jeff Roberts on 5/30/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

public protocol ContentFilter : class {
    func apply(message : String) -> Bool
}

//
// BasicContentFilter is a ContentFilter that can filter based upon whether the logged
// messages beginsWith, contains or endsWith a collection of Strings. You can specify
// any combination of beginsWith, contains or endsWith and the filter will answer true
// if ANY of the values match. The comparison is case sensitive so "hello" does not match "Hello"
// or "heLLO". It is additive, so you can invoke one of the functions multiple times and the
// speccified values will be accumulated.
//
// Example:
// let filter = BasicContentFilter()
// filter.beginsWith("abc", "def")
// filter.beginsWith("xyz", "123")
//
// This will result in a BasicContentFilter that will check if the message to be logged
// beginsWith "abc" or "def" or "xyz" or "123".
//
// You can combine the beginsWith with any combination of contains and/or endsWith.
//
// Example:
// // let filter = BasicContentFilter()
// filter.beginsWith("abc", "def")
// filter.contains("xyz", "123")
// filter.endsWith("321")
//
// This will result in a BasicContentFilter that will check if the message to be logged
// beginsWith "abc or "def" or contains "xyz" or "123" or endsWith "321".
//
// The BasicContentFilter API is fluent, meaning that invoking beginsWith, contains or
// endsWith returns self allowing you to fluently call other API functions.
//
// Example (fluent API)
// let filter = BasicContentFilter()
// filter.beginsWith("abc")
//      .contains("123")
//      .endsWith("abc123")
//
public class BasicContentFilter : ContentFilter {
    var beginsWith : [String]?
    var contains : [String]?
    var endsWith: [String]?

    public init() {}

    public func beginsWith(strings : String...) -> BasicContentFilter {
        if beginsWith == nil {
            beginsWith = []
        }

        strings.forEach {
            string in
            beginsWith?.append(string)
        }

        return self
    }

    public func contains(strings : String...) -> BasicContentFilter {
        if contains == nil {
            contains = []
        }

        strings.forEach {
            string in
            contains?.append(string)
        }

        return self
    }

    public func endsWith(strings : String...) -> BasicContentFilter {
        if endsWith == nil {
            endsWith = []
        }

        strings.forEach {
            string in
            endsWith?.append(string)
        }

        return self
    }

    // ContentFilter
    public func apply(message : String) -> Bool {
        guard beginsWith != nil || contains != nil || endsWith != nil else {
            return true
        }

        return beginsWith?.filter {
            prefix in
            return message.hasPrefix(prefix)
        }.count > 0 || contains?.filter {
            string in
            return message.containsString(string)
        }.count > 0 || endsWith?.filter {
            suffix in
            return message.hasSuffix(suffix)
        }.count > 0
    }
}