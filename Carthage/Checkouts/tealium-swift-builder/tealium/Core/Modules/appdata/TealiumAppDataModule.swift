//
//  AppData.swift
//  TealiumSwift
//
//  Created by Craig Rouse on 27/11/2019.
//  Copyright © 2019 Tealium. All rights reserved.
//

import Foundation

public class TealiumAppDataModule: Collector, TealiumAppDataCollection {
    public var data: [String: Any]? {
        if self.config.shouldCollectTealiumData {
            return appData.dictionary
        } else {
            return appData.persistentData?.dictionary
        }
    }
    
    public let moduleId: String = "App Data"

    private(set) var uuid: String?
    private var diskStorage: TealiumDiskStorageProtocol!
    private var bundle: Bundle
    var appData = AppData()
    var existingVisitorId: String? {
        config.existingVisitorId
    }
    var logger: TealiumLoggerProtocol? {
        config.logger
    }
    
    public var config: TealiumConfig
    
    convenience init(config: TealiumConfig,
                  delegate: TealiumModuleDelegate,
                  diskStorage: TealiumDiskStorageProtocol?,
                  bundle: Bundle) {
        self.init(config: config, delegate: delegate, diskStorage: diskStorage) { result in }
        self.bundle = bundle
    }

    required public init(config: TealiumConfig,
                         delegate: TealiumModuleDelegate?,
                         diskStorage: TealiumDiskStorageProtocol?,
                         completion: ModuleCompletion) {
        self.config = config
        self.bundle = Bundle.main
        self.diskStorage = diskStorage ?? TealiumDiskStorage(config: config, forModule: "appdata", isCritical: true)
        setExistingAppData()
        completion((.success(true), nil))
    }

    /// Retrieves existing data from persistent storage and stores in volatile memory.
    func setExistingAppData() {
        guard let data = diskStorage.retrieve(as: PersistentAppData.self) else {
            setNewAppData()
            return
        }
        self.setLoadedAppData(data: data)
    }

    /// Deletes all app data, including persistent data.
    func deleteAllData() {
       appData.removeAll()
       diskStorage.delete(completion: nil)
    }

    /// - Returns: Count of total items in app data
    var count: Int {
       return appData.count
    }

    // MARK: INTERNAL

    /// Checks if persistent keys are missing from the `data` dictionary.
    ///
    /// - Parameter data: `[String: Any]` dictionary to check
    /// - Returns: `Bool`
    class func isMissingPersistentKeys(data: [String: Any]) -> Bool {
       if data[TealiumKey.uuid] == nil { return true }
       if data[TealiumKey.visitorId] == nil { return true }
       return false
    }

    /// Converts UUID to Tealium Visitor ID format.
    ///
    /// - Parameter from: `String` containing a UUID
    /// - Returns: `String` containing Tealium Visitor ID
    func visitorId(from uuid: String) -> String {
       return uuid.replacingOccurrences(of: "-", with: "")
    }

    /// Prepares new Tealium default App related data. Legacy Visitor Id data
    /// is set here as it based off app_uuid.
    ///
    /// - Parameter uuid: The uuid string to use for new persistent data.
    /// - Returns: `[String:Any]`
    func newPersistentData(for uuid: String) -> PersistentAppData {
       let visitorId = existingVisitorId ?? self.visitorId(from: uuid)
       let persistentData = PersistentAppData(visitorId: visitorId, uuid: uuid)
       diskStorage.saveToDefaults(key: TealiumKey.visitorId, value: visitorId)
       diskStorage?.save(persistentData, completion: nil)
       return persistentData
    }

    /// Generates a new set of Volatile Data (usually once per app launch)
    func newVolatileData() {
       if let name = name(bundle: bundle) {
           appData.name = name
       }

       if let rdns = rdns(bundle: bundle) {
           appData.rdns = rdns
       }

       if let version = version(bundle: bundle) {
           appData.version = version
       }

       if let build = build(bundle: bundle) {
           appData.build = build
       }
    }

    /// Stores current AppData in memory
    func setNewAppData() {
       let newUUID = UUID().uuidString
       appData.persistentData = newPersistentData(for: UUID().uuidString)
       newVolatileData()
       uuid = newUUID
    }

    /// Populates in-memory AppData with existing values from persistent storage, if present.
    ///
    /// - Parameter data: `PersistentAppData` instance  containing existing AppData variables
    func setLoadedAppData(data: PersistentAppData) {
       guard !TealiumAppDataModule.isMissingPersistentKeys(data: data.dictionary) else {
           setNewAppData()
           return
       }

       appData.persistentData = data
       if let existingVisitorId = self.existingVisitorId,
           let persistentData = appData.persistentData {
           let newPersistentData = PersistentAppData(visitorId: existingVisitorId, uuid: persistentData.uuid)
           diskStorage.saveToDefaults(key: TealiumKey.visitorId, value: existingVisitorId)
           diskStorage.save(newPersistentData, completion: nil)
           self.appData.persistentData = newPersistentData
       }
       newVolatileData()
    }

}
