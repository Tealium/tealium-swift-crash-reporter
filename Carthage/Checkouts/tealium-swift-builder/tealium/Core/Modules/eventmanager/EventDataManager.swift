//
//  EventDataManager.swift
//  TealiumSwift
//
//  Created by Craig Rouse on 4/21/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation

public class EventDataManager: EventDataManagerProtocol, TimestampCollection {
 
    var data = Set<EventDataItem>()
    var diskStorage: TealiumDiskStorageProtocol
    var restartData = [String: Any]()
    public var lastTrackDate: Date?
    public var minutesBetweenSessionIdentifier: TimeInterval
    public var numberOfTracksBacking = 0
    public var secondsBetweenTrackEvents: TimeInterval = TealiumKey.defaultsSecondsBetweenTrackEvents
    public var sessionData = [String: Any]()
    public var sessionStarter: SessionStarterProtocol
    public var shouldTriggerSessionRequest = false
    public var tagManagementIsEnabled = false
    
    public init(config: TealiumConfig,
        diskStorage: TealiumDiskStorageProtocol? = nil,
        sessionStarter: SessionStarterProtocol? = nil) {
        self.diskStorage = diskStorage ?? TealiumDiskStorage(config: config, forModule: "eventdata")
        self.sessionStarter = sessionStarter ?? SessionStarter(config: config)
        self.minutesBetweenSessionIdentifier = TimeInterval(TealiumKey.defaultMinutesBetweenSession)
        var currentStaticData = [TealiumKey.account: config.account,
            TealiumKey.profile: config.profile,
            TealiumKey.environment: config.environment,
            TealiumKey.libraryName: TealiumValue.libraryName,
            TealiumKey.libraryVersion: TealiumValue.libraryVersion]
       
        if let dataSource = config.datasource {
            currentStaticData[TealiumKey.dataSource] = dataSource
        }
        add(data: currentStaticData, expiration: .untilRestart)
        sessionRefresh()
    }
    
    /// - Returns: `[String: Any]` containing all stored event data.
    public var allEventData: [String: Any] {
        get {
            var allData = [String: Any]()
            if let persistentData = self.persistentDataStorage {
                allData += persistentData.allData
            }
            allData += self.restartData
            allData += self.allSessionData
            return allData
        }
        set {
            self.add(data: newValue, expiration: .forever)
        }
    }
    
    /// - Returns: `[String: Any]` containing all data for the active session.
    public var allSessionData: [String: Any] {
        get {
            var allSessionData = [String: Any]()
            if let persistentData = self.persistentDataStorage {
                allSessionData += persistentData.allData
            }
            
            allSessionData[TealiumKey.random] = "\(Int.random(in: 1...16))"
            if !currentTimestampsExist(allSessionData) {
                allSessionData.merge(currentTimeStamps) { _ , new in new }
                allSessionData[TealiumKey.timestampOffset] = timezoneOffset
            }
            allSessionData += sessionData
            return allSessionData
        }
    }

    /// - Returns: `[String: Any]` containing all current timestamps in volatile data.
    public var currentTimeStamps: [String: Any] {
        let date = Date()
        return [
            TealiumKey.timestampEpoch: date.timestampInSeconds,
            TealiumKey.timestamp: date.iso8601String,
            TealiumKey.timestampLocal: date.iso8601LocalString,
            TealiumKey.timestampUnixMilliseconds: date.unixTimeMilliseconds,
            TealiumKey.timestampUnix: date.unixTimeSeconds
        ]
    }
    
    /// - Returns: `EventData` containing all stored event data.
    public var persistentDataStorage: EventData? {
        get {
            guard let storedData = self.diskStorage.retrieve(as: EventData.self) else {
                return EventData()
            }
            return storedData
        }
        set {
            if let newData = newValue?.removeExpired() {
                self.diskStorage.save(newData, completion: nil)
            }
        }
    }
    
    /// - Returns: `String` containing the offset from UTC in hours.
    var timezoneOffset: String {
        let timezone = TimeZone.current
        let offsetSeconds = timezone.secondsFromGMT()
        let offsetHours = offsetSeconds / 3600
        return String(format: "%i", offsetHours)
    }

    /// Adds data to be stored based on the `Expiraton`.
    /// - Parameters:
    ///   - key: `String` name of key to be stored.
    ///   - value: `Any` should be `String` or `[String]`.
    ///   - expiration: `Expiration` level.
    public func add(key: String,
        value: Any,
        expiration: Expiration) {
        self.add(data: [key: value], expiration: expiration)
    }

    /// Adds data to be stored based on the `Expiraton`.
    /// - Parameters:
    ///   - data: `[String: Any]` to be stored.
    ///   - expiration: `Expiration` level.
    public func add(data: [String: Any],
        expiration: Expiration) {
        switch expiration {
        case .session:
            self.sessionData += data
            self.persistentDataStorage?.insertNew(from: self.sessionData, expires: expiration.date)
        case .untilRestart:
            self.restartData += data
            self.persistentDataStorage?.insertNew(from: self.restartData, expires: expiration.date)
        default:
            self.persistentDataStorage?.insertNew(from: data, expires: expiration.date)
            break
        }
        
    }
    
    /// Checks that the active session data contains all expected timestamps.
    ///
    /// - Parameter currentData: `[String: Any]` containing existing session data.
    /// - Returns: `Bool` `true` if current timestamps exist in active session data.
    func currentTimestampsExist(_ currentData: [String: Any]) -> Bool {
        TealiumQueues.backgroundConcurrentQueue.read {
            currentData[TealiumKey.timestampEpoch] != nil &&
                currentData[TealiumKey.timestamp] != nil &&
                currentData[TealiumKey.timestampLocal] != nil &&
                currentData[TealiumKey.timestampOffset] != nil &&
                currentData[TealiumKey.timestampUnix] != nil
        }
    }
    
    /// Deletes specified values from storage.
    /// - Parameter forKeys: `[String]` keys to delete.
    public func delete(forKeys: [String]) {
        forKeys.forEach {
            self.delete(forKey: $0)
        }
    }
    
    /// Deletes a value from storage.
    /// - Parameter key: `String` to delete.
    public func delete(forKey key: String) {
        persistentDataStorage?.remove(key: key)
    }
    
    /// Deletes all values from storage.
    public func deleteAll() {
        persistentDataStorage?.removeAll()
    }

}
