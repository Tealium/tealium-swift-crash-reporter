//
//  TealiumLocationModule.swift
//  TealiumLocation
//
//  Created by Harry Cassell on 09/09/2019.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//
#if os(iOS)
import Foundation
#if location
import TealiumCore
#endif

/// Module to add app related data to track calls.
class TealiumLocationModule: Collector {
    
    public let moduleId: String = "Location"
    var config: TealiumConfig
    weak var delegate: TealiumModuleDelegate?
    var tealiumLocationManager: TealiumLocation?
    
    var data: [String : Any]? {
        var newData = [String: Any]()
        guard let tealiumLocationManager = tealiumLocationManager else {
            return nil
        }
        let location = tealiumLocationManager.latestLocation
        if location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0 {
            newData = [TealiumLocationKey.deviceLatitude: "\(location.coordinate.latitude)",
                TealiumLocationKey.deviceLongitude: "\(location.coordinate.longitude)",
                TealiumLocationKey.accuracy: tealiumLocationManager.locationAccuracy]
        }
        return newData
    }
    
    required init(config: TealiumConfig, delegate: TealiumModuleDelegate?, diskStorage: TealiumDiskStorageProtocol?, completion: (ModuleResult) -> Void) {
        self.config = config
        self.delegate = delegate
        
        if Thread.isMainThread {
            tealiumLocationManager = TealiumLocation(config: config, locationListener: self)
        } else {
            TealiumQueues.mainQueue.async {
                self.tealiumLocationManager = TealiumLocation(config: config, locationListener: self)
            }
        }
        
    }

    /// Disables the module and deletes all associated data
    func disable() {
        tealiumLocationManager?.disable()
    }

}

extension TealiumLocationModule: LocationListener {
    
    func didEnterGeofence(_ data: [String: Any]) {
        let trackRequest = TealiumTrackRequest(data: data, completion: nil)
        delegate?.requestTrack(trackRequest)
    }

    func didExitGeofence(_ data: [String: Any]) {
        let trackRequest = TealiumTrackRequest(data: data, completion: nil)
        delegate?.requestTrack(trackRequest)
    }
}
#endif
