//
//  TealiumPersistentData.swift
//  ios
//
//  Created by Craig Rouse on 11/07/2019.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//

import Foundation

public class TealiumPersistentData {

    var eventDataManager: EventDataManagerProtocol
    
    public init(eventDataManager: EventDataManagerProtocol) {
        self.eventDataManager = eventDataManager
    }

    /// `[String: Any]` containing all active persistent data.
    public var dictionary: [String: Any]? {
        eventDataManager.allEventData
    }

    /// Add additional persistent data that will be available to all track calls
    ///     for lifetime of app. Values will overwrite any pre-existing values
    ///     for a given key.
    ///￼
    /// - Parameter data: `[String:Any]` of additional data to add.
    /// - Parameter expiration: `Expiration` level.
    public func add(data: [String: Any], expiration: Expiration = .forever) {
        eventDataManager.add(data: data, expiration: expiration)
    }
    
    /// Add additional persistent data that will be available to all track calls
    ///     for lifetime of app. Values will overwrite any pre-existing values
    ///     for a given key.
    ///￼
    /// - Parameter value: `Any` should be `String` or `[String]`.
    /// - Parameter key: `String` name of key to be added.
    /// - Parameter expiration: `Expiration` level.
    public func add(value: Any,
                    forKey key: String,
                    expiration: Expiration = .forever) {
        eventDataManager.add(key: key, value: value, expiration: expiration)
    }

    /// Delete a saved value for a given key.
    ///￼
    /// - Parameter forKeys: `[String]` Array of keys to remove.
    public func deleteData(forKeys: [String]) {
        eventDataManager.delete(forKeys: forKeys)
    }
    
    /// Deletes persistent data for a specific key.
    /// - Parameter key: `String` to remove a specific value from the internal session data store.
    public func delete(forKey key: String) {
        eventDataManager.delete(forKey: key)
    }

    /// Deletes all custom persisted data for current library instance.
    public func deleteAllData() {
        eventDataManager.deleteAll()
    }

}
