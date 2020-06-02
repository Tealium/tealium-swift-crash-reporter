//
//  TealiumLifecyclePersistentData.swift
//  tealium-swift
//
//  Created by Jason Koo on 11/17/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

import Foundation
#if lifecycle
import TealiumCore
#endif

// Can get rid of this file

enum TealiumLifecyclePersistentDataError: Error {
    case couldNotArchiveAsData
    case couldNotUnarchiveData
    case archivedDataMismatchWithOriginalData
}

open class TealiumLifecyclePersistentData {

    let diskStorage: TealiumDiskStorageProtocol

    init(diskStorage: TealiumDiskStorageProtocol,
         uniqueId: String? = nil) {
        self.diskStorage = diskStorage
    }

    class func dataExists(forUniqueId: String) -> Bool {
        guard UserDefaults.standard.object(forKey: forUniqueId) as? Data != nil else {
            return false
        }

        return true
    }

    func load() -> TealiumLifecycle? {
        return diskStorage.retrieve(as: TealiumLifecycle.self)
    }

    func save(_ lifecycle: TealiumLifecycle) -> (success: Bool, error: Error?) {
        diskStorage.save(lifecycle, completion: nil)
        return (true, nil)
    }

    class func deleteAllData(forUniqueId: String) -> Bool {
        if !dataExists(forUniqueId: forUniqueId) {
            return true
        }

        UserDefaults.standard.removeObject(forKey: forUniqueId)

        if UserDefaults.standard.object(forKey: forUniqueId) == nil {
            return true
        }

        return false
    }

}
