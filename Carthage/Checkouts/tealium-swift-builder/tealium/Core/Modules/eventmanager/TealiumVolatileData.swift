//
//  TealiumVolatileData.swift
//  TealiumSwift
//
//  Created by Jonathan Wong on 1/10/18.
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

import Foundation

public class TealiumVolatileData {

    var eventDataManager: EventDataManagerProtocol

    public init(eventDataManager: EventDataManagerProtocol) {
        self.eventDataManager = eventDataManager
    }
    
    /// `[String: Any]` containing all active session data.
    @available(*, deprecated, message: "Please use volatileData().dictionary")
    public func getData() -> [String: Any] {
        dictionary
    }
    
    /// `[String: Any]` containing all active session data.
    public var dictionary: [String: Any] {
        eventDataManager.allSessionData
    }

    /// Add data to all dispatches for the remainder of an active session.
    ///
    /// - Parameter data: `[String: Any]`. Values should be of type `String` or `[String]`
    public func add(data: [String: Any]) {
        self.eventDataManager.add(data: data, expiration: .session)
    }
    
    /// Adds values to all dispatches for the remainder of an active session.
    /// - Parameters:
    ///   - value: Values should be of type `String` or `[String]`
    ///   - key: `String`
    public func add(value: Any, forKey key: String) {
        self.eventDataManager.add(key: key, value: value, expiration: .session)
    }

    /// Deletes session data for specific keys.
    ///
    /// - Parameter keys: `[String]` to remove from the internal session data store.
    public func deleteData(forKeys keys: [String]) {
        self.eventDataManager.delete(forKeys: keys)
    }

    /// Deletes session data for a specific key.
    /// - Parameter key: `String` to remove a specific value from the internal session data store.
    public func delete(for key: String) {
        self.eventDataManager.delete(forKey: key)
    }

    /// Deletes all session data.
    public func deleteAllData() {
        self.eventDataManager.sessionData = [String: Any]()
    }

}

