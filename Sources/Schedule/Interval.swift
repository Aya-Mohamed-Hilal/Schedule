//
//  Interval.swift
//  Schedule
//
//  Created by Quentin Jin on 2018/7/17.
//

import Foundation

/// `Interval` represents a duration of time.
public struct Interval {
    
    ///  The length of this interval, measured in nanoseconds.
    public let nanoseconds: Double
    
    /// Creates an interval from the given number of nanoseconds.
    public init(nanoseconds: Double) {
        self.nanoseconds = nanoseconds
    }
    
    /// A boolean value indicating whether this interval is negative.
    ///
    /// A interval can be negative.
    ///
    /// - The interval between 6:00 and 7:00 is `1.hour`,
    /// but the interval between 7:00 and 6:00 is `-1.hour`.
    /// In this case, `-1.hour` means **one hour ago**.
    ///
    /// - The interval comparing `3.hour` and `1.hour` is `2.hour`,
    /// but the interval comparing `1.hour` and `3.hour` is `-2.hour`.
    /// In this case, `-2.hour` means **two hours shorter**
    public var isNegative: Bool {
        return nanoseconds.isLess(than: 0)
    }
    
    /// The magnitude of this interval.
    ///
    /// It's the absolute value of the length of this interval,
    /// measured in nanoseconds, but disregarding its sign.
    public var magnitude: Double {
        return nanoseconds.magnitude
    }
    
    internal var ns: Int {
        if nanoseconds > Double(Int.max) { return .max }
        if nanoseconds < Double(Int.min) { return .min }
        return Int(nanoseconds)
    }
    
    /// Returns a dispatchTimeInterval created from this interval.
    ///
    /// The returned value will be clamped to the `DispatchTimeInterval`'s
    /// usable range [`.nanoseconds(.min)....nanoseconds(.max)`].
    public func asDispatchTimeInterval() -> DispatchTimeInterval {
        return .nanoseconds(ns)
    }
    
    /// Returns a boolean value indicating whether this interval is longer than the given value.
    public func isLonger(than other: Interval) -> Bool {
        return magnitude > other.magnitude
    }
    
    /// Returns a boolean value indicating whether this interval is shorter than the given value.
    public func isShorter(than other: Interval) -> Bool {
        return magnitude < other.magnitude
    }
    
    /// Returns the longest interval of the given values.
    public static func longest(_ intervals: Interval...) -> Interval {
        return intervals.sorted(by: { $0.magnitude > $1.magnitude })[0]
    }
    
    /// Returns the shortest interval of the given values.
    public static func shortest(_ intervals: Interval...) -> Interval {
        return intervals.sorted(by: { $0.magnitude < $1.magnitude })[0]
    }
    
    /// Returns a new interval by multipling the left interval by the right number.
    ///
    ///     1.hour * 2 == 2.hours
    public static func *(lhs: Interval, rhs: Double) -> Interval {
        return Interval(nanoseconds: lhs.nanoseconds * rhs)
    }
    
    /// Returns a new interval by adding the right interval to the left interval.
    ///
    ///     1.hour + 1.hour == 2.hours
    public static func +(lhs: Interval, rhs: Interval) -> Interval {
        return Interval(nanoseconds: lhs.nanoseconds + rhs.nanoseconds)
    }
    
    /// Returns a new instarval by subtracting the right interval from the left interval.
    ///
    ///     2.hours - 1.hour == 1.hour
    public static func -(lhs: Interval, rhs: Interval) -> Interval {
        return Interval(nanoseconds: lhs.nanoseconds - rhs.nanoseconds)
    }
}

extension Interval {
    
    /// Creates an interval from the given number of seconds.
    public init(seconds: Double) {
        self.nanoseconds = seconds * pow(10, 9)
    }
    
    /// The length of this interval, measured in seconds.
    public var seconds: Double {
        return nanoseconds / pow(10, 9)
    }
    
    /// The length of this interval, measured in minutes.
    public var minutes: Double {
        return seconds / 60
    }
    
    /// The length of this interval, measured in hours.
    public var hours: Double {
        return minutes / 60
    }
    
    /// The length of this interval, measured in days.
    public var days: Double {
        return hours / 24
    }
    
    /// The length of this interval, measured in weeks.
    public var weeks: Double {
        return days / 7
    }
}

extension Interval: Hashable {
    
    /// The hashValue of this interval.
    public var hashValue: Int {
        return nanoseconds.hashValue
    }
    
    /// Returns a boolean value indicating whether the interval is equal to another interval.
    public static func ==(lhs: Interval, rhs: Interval) -> Bool {
        return lhs.nanoseconds == rhs.nanoseconds
    }
}

extension Date {
    
    /// The interval between this date and now.
    ///
    /// If the date is earlier than now, the interval is negative.
    public var intervalSinceNow: Interval {
        return timeIntervalSinceNow.seconds
    }
    
    /// Returns the interval between this date and the given date.
    ///
    /// If the date is earlier than the given date, the interval is negative.
    public func interval(since date: Date) -> Interval {
        return timeIntervalSince(date).seconds
    }
    
    /// Return a new date by adding an interval to the date.
    public static func +(lhs: Date, rhs: Interval) -> Date {
        return lhs.addingTimeInterval(rhs.seconds)
    }
    
    /// Add an interval to the date.
    public static func +=(lhs: inout Date, rhs: Interval) {
        lhs = lhs + rhs
    }
}

/// `IntervalConvertible` provides a set of intuitive apis for creating interval.
public protocol IntervalConvertible {
    
    var nanoseconds: Interval { get }
}

extension Int: IntervalConvertible {
    
    public var nanoseconds: Interval {
        return Interval(nanoseconds: Double(self))
    }
}

extension Double: IntervalConvertible {
    
    public var nanoseconds: Interval {
        return Interval(nanoseconds: self)
    }
}

extension IntervalConvertible {
    
    public var nanosecond: Interval {
        return nanoseconds
    }
    
    public var microsecond: Interval {
        return microseconds
    }
    
    public var microseconds: Interval {
        return nanoseconds * pow(10, 3)
    }
    
    public var millisecond: Interval {
        return milliseconds
    }
    
    public var milliseconds: Interval {
        return nanoseconds * pow(10, 6)
    }
    
    public var second: Interval {
        return seconds
    }
    
    public var seconds: Interval {
        return nanoseconds * pow(10, 9)
    }
    
    public var minute: Interval {
        return minutes
    }
    
    public var minutes: Interval {
        return seconds * 60
    }
    
    public var hour: Interval {
        return hours
    }
    
    public var hours: Interval {
        return minutes * 60
    }
    
    public var day: Interval {
        return days
    }
    
    public var days: Interval {
        return hours * 24
    }
    
    public var week: Interval {
        return weeks
    }
    
    public var weeks: Interval {
        return days * 7
    }
}
