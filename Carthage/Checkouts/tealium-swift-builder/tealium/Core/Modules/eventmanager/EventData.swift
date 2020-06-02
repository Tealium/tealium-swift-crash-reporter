//
//  EventData.swift
//  TealiumSwift
//
//  Created by Craig Rouse on 4/21/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation

public typealias EventData = Set<EventDataItem>

extension EventData {

    /// Inserts a new `EventDataItem` into the `EventData` store
    /// If a value for that key already exists, it will be removed before
    /// the new value is inserted.
    /// - Parameters:
    ///   - dictionary: `[String: Any]` values being inserted into the `EventData` store
    ///   - expires: `Date` expiration date
    public mutating func insertNew(from dictionary: [String: Any], expires: Date) {
        dictionary.forEach { item in
            if let existing = self.filter({ (value) -> Bool in
                return value.key == item.key
            }).first {
                self.remove(existing)
            }
            let eventDataValue = EventDataItem(key: item.key, value: item.value, expires: expires)
            self.insert(eventDataValue)
        }
    }

    /// Inserts a new `EventDataItem` into the `EventData` store
    /// If a value for that key already exists, it will be removed before
    /// the new value is inserted.
    /// - Parameters:
    ///   - key: `String` name for the value
    ///   - value: `Any` should be `String` or `[String]`
    ///   - expires: `Date` expiration date
    public mutating func insertNew(key: String, value: Any, expires: Date) {
        self.insertNew(from: [key: value], expires: expires)
    }

    /// Removes the `EventDataItem` from the `EventData` store
    /// - Parameter key: `String` name of key to remove
    public mutating func remove(key: String) {
        self.filter {
            $0.key == key
        }.forEach {
            remove($0)
        }
    }

    /// Removes expired data from the `EventData` store
    /// - Returns: `EventData` after removal
    public func removeExpired() -> EventData {
        let currentDate = Date()
        let newEventData = self.filter {
            $0.expires > currentDate
        }
        return newEventData
    }

    /// - Returns: `[String: Any]` all the data currently in the `EventData` store
    public var allData: [String: Any] {
        var returnData = [String: Any]()
        self.forEach { eventDataItem in
            returnData[eventDataItem.key] = eventDataItem.value
        }
        return returnData
    }

}

public struct EventDataItem: Codable, Hashable {
    public static func == (lhs: EventDataItem, rhs: EventDataItem) -> Bool {
        lhs.key == rhs.key
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }

    var key: String
    var value: Any
    var expires: Date

    enum CodingKeys: String, CodingKey {
        case key
        case value
        case expires
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(AnyCodable(value), forKey: .value)
        try container.encode(expires, forKey: .expires)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let decoded = try values.decode(AnyCodable.self, forKey: .value)
        value = decoded.value
        expires = try values.decode(Date.self, forKey: .expires)
        key = try values.decode(String.self, forKey: .key)
    }

    public init(key: String,
        value: Any,
        expires: Date) {
        self.key = key
        self.value = value
        self.expires = expires
    }
}
