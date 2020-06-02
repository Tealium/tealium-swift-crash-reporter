//
//  TealiumExtensions.swift
//  tealium-swift
//
//  Created by Jason Koo on 11/1/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

/// General Extensions that may be used by multiple objects.
import Foundation

/// Extend boolvalue NSString function to Swift strings.
extension String {
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}

extension Dictionary where Key == String, Value == Any {

    mutating func safelyAdd(key: String, value: Any?) {
        if let value = value {
            self += [key: value]
        }
    }

}

/// Allows use of plus operator for array reduction calls.
func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    rhs.forEach { result[$0] = $1 }
    return result
}

extension Date {

    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            return formatter
        }()
        static let extendedIso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(abbreviation: "GMT")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            return formatter
        }()
        static let MMDDYYYY: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "MM/dd/yyyy"
            return formatter
        }()
        static let iso8601Local: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
            // note that local time should NOT have a 'Z' after it, as the 'Z' indicates UTC (zero meridian)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'"
            return formatter
        }()
    }

    public var iso8601String: String {
        return Formatter.iso8601.string(from: self)
    }
    
    public var extendedIso8601String: String {
        return Formatter.extendedIso8601.string(from: self).appending("Z")
    }

    public var iso8601LocalString: String {
        return Formatter.iso8601Local.string(from: self)
    }

    public var mmDDYYYYString: String {
        return Formatter.MMDDYYYY.string(from: self)
    }

    public var unixTimeMilliseconds: String {
        // must be forced to Int64 to avoid overflow on watchOS (32 bit)
        let time = Int64(self.timeIntervalSince1970 * 1000)

        return String(describing: time)
    }

    public var unixTimeSeconds: String {
        // must be forced to Int64 to avoid overflow on watchOS (32 bit)
        let time = Int64(self.timeIntervalSince1970)

        return String(describing: time)
    }

    public func millisecondsFrom(earlierDate: Date) -> Int64 {
        return Int64(self.timeIntervalSince(earlierDate) * 1000)
    }
}

public extension Array {
    // Credit: https://gist.github.com/ericdke/fa262bdece59ff786fcb#gistcomment-2045033
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
