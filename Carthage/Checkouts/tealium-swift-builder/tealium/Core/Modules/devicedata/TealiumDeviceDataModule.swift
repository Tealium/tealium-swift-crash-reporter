//
//  TealiumDeviceDataModule.swift
//  tealium-swift
//
//  Created by Jason Koo on 8/3/17.
//  Copyright © 2017 Tealium, Inc. All rights reserved.
//

#if os(OSX)
#else
import UIKit
#endif
import Foundation
#if os(tvOS)
#elseif os (watchOS)
#else
import CoreTelephony
#endif
#if os(watchOS)
import WatchKit
#endif

class DeviceDataModule: Collector {
    let moduleId: String = "Device Data"
    
    var data: [String: Any]? {
        get {
            guard config.shouldCollectTealiumData else {
                return nil
            }
            cachedData += trackTimeData()
            return cachedData
        }
    }

    var isMemoryEnabled: Bool {
        config.memoryReportingEnabled
    }
    var deviceDataCollection: TealiumDeviceDataCollection
    var cachedData = [String: Any]()
    var config: TealiumConfig

    required init(config: TealiumConfig,
                  delegate: TealiumModuleDelegate?,
                  diskStorage: TealiumDiskStorageProtocol?,
                  completion: ModuleCompletion) {
        self.config = config
        deviceDataCollection = TealiumDeviceData()
        cachedData = enableTimeData()
        completion((.success(true), nil))
    }

    /// Data that only needs to be retrieved once for the lifetime of the host app.
    ///
    /// - Returns: `[String:Any]` of enable-time device data.
    func enableTimeData() -> [String: Any] {
        var result = [String: Any]()

        result[TealiumKey.architectureLegacy] = deviceDataCollection.architecture()
        result[TealiumKey.architecture] = result[TealiumKey.architectureLegacy] ?? ""
        result[TealiumDeviceDataKey.osBuildLegacy] = TealiumDeviceData.oSBuild()
        result[TealiumDeviceDataKey.osBuild] = TealiumDeviceData.oSBuild()
        result[TealiumKey.cpuTypeLegacy] = deviceDataCollection.cpuType()
        result[TealiumKey.cpuType] = result[TealiumKey.cpuTypeLegacy] ?? ""
        result.merge(deviceDataCollection.model()) { _, new -> Any in
            new
        }
        result[TealiumDeviceDataKey.osVersionLegacy] = TealiumDeviceData.oSVersion()
        result[TealiumDeviceDataKey.osVersion] = result[TealiumDeviceDataKey.osVersionLegacy] ?? ""
        result[TealiumKey.osName] = TealiumDeviceData.oSName()
        result[TealiumKey.platform] = result[TealiumKey.osName] ?? ""
        result[TealiumKey.resolution] = TealiumDeviceData.resolution()
        return result
    }

    /// Data that needs to be polled at time of interest, these may change during the lifetime of the host app.
    ///
    /// - Returns: `[String: Any]` of track-time device data.
    func trackTimeData() -> [String: Any] {
        var result = [String: Any]()

        result[TealiumDeviceDataKey.batteryPercentLegacy] = TealiumDeviceData.batteryPercent()
        result[TealiumDeviceDataKey.batteryPercent] = result[TealiumDeviceDataKey.batteryPercentLegacy] ?? ""
        result[TealiumDeviceDataKey.isChargingLegacy] = TealiumDeviceData.isCharging()
        result[TealiumDeviceDataKey.isCharging] = result[TealiumDeviceDataKey.isChargingLegacy] ?? ""
        result[TealiumKey.languageLegacy] = TealiumDeviceData.iso639Language()
        result[TealiumKey.language] = result[TealiumKey.languageLegacy] ?? ""
        if isMemoryEnabled {
            result.merge(deviceDataCollection.getMemoryUsage()) { _, new -> Any in
                new
            }
        }
        result.merge(deviceDataCollection.orientation()) { _, new -> Any in
            new
        }
        result.merge(TealiumDeviceData.carrierInfo()) { _, new -> Any in
            new
        }
        return result
    }
}
