//
//  TealiumAttributionModule.swift
//  tealium-swift
//
//  Created by Jason Koo on 11/16/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//
#if os(iOS)
import Foundation
#if attribution
import TealiumCore
#endif

class TealiumAttributionModule: Collector {
    let moduleId: String = "Attribution"

    var data: [String: Any]? {
        self.attributionData.allAttributionData
    }

    var collectorId = "Attribution"

    var attributionData: TealiumAttributionDataProtocol!
    var diskStorage: TealiumDiskStorageProtocol!
    public var config: TealiumConfig

    /// Provided for unit testing￼.
    ///
    /// - Parameter attributionData: Class instance conforming to `TealiumAttributionDataProtocol`
    convenience init (config: TealiumConfig,
                      delegate: TealiumModuleDelegate?,
                      diskStorage: TealiumDiskStorageProtocol?,
        attributionData: TealiumAttributionDataProtocol) {
        self.init(config: config, delegate: delegate, diskStorage: diskStorage) { result in }
        self.attributionData = attributionData
    }

    required public init(config: TealiumConfig,
                         delegate: TealiumModuleDelegate?,
                         diskStorage: TealiumDiskStorageProtocol?,
                         completion: ModuleCompletion) {
        self.config = config
        self.diskStorage = diskStorage ?? TealiumDiskStorage(config: config, forModule: "attribution", isCritical: false)
        self.attributionData = TealiumAttributionData(diskStorage: self.diskStorage,
                                                      isSearchAdsEnabled: config.searchAdsEnabled)
        completion((.success(true), nil))
    }

}
#endif
