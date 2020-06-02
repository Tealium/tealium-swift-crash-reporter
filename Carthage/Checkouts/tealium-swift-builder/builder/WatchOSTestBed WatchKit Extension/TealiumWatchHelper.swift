//
//  TealiumWatchHelper.swift
//  SwiftTestbed
//
//  Created by Jason Koo on 11/22/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

import Foundation
import TealiumCore
import TealiumCollect
import TealiumVisitorService
import TealiumLifecycle

//import WatchOS

extension String: Error {}

/// Example of a shared helper to handle all 3rd party tracking services. This
/// paradigm is recommended to reduce burden of future code updates for external services
/// in general.
/// Note: TealiumWatchHelper class inherits from NSObject to allow @objc annotations and Objective-C interop.
/// If you don't need this, you may omit @objc annotations and NSObject inheritance.
class TealiumWatchHelper: NSObject {

    static let shared = TealiumWatchHelper()
    var tealium: Tealium?
    var enableHelperLogs = false
    var traceId = "04136"

    override private init () {

    }

    func start() {
        // REQUIRED Config object for lib
        let config = TealiumConfig(account: "tealiummobile",
                                   profile: "demo",
                                   environment: "dev",
                                   datasource: "test12",
                                   optionalData: nil)

        // OPTIONALLY set log level
//        config.setConnectivityRefreshInterval(5)
        config.logLevel = .info
//        config.setConsentLoggingEnabled(true)
//        config.setSearchAdsEnabled(true)
        config.setInitialUserConsentStatus(.consented)
//        config.setShouldUseLegacyWebview(true)
//        config.setBatchSize(5)
//        config.setDispatchAfter(numberOfEvents: 5)
        config.setMaxQueueSize(200)
        config.optionalData["enable_visitor_profile"] = true
        config.setIsEventBatchingEnabled(true)
        // OPTIONALLY add an external delegate
//        config.addDelegate(self)
        config.setMemoryReportingEnabled(true)
//        config.setConnectivityRefreshEnabled(true)
//        config.setConnectivityRefreshInterval(30)
        #if AUTOTRACKING
//        print("*** TealiumWatchHelper: Autotracking enabled.")
        #else
        // OPTIONALLY disable a particular module by name
        
        let list = TealiumModulesList(isWhitelist: false,
                                      moduleNames: ["autotracking"])
//        config.setModulesList(list)
        config.setDiskStorageEnabled(isEnabled: true)
//        config.addVisitorServiceDelegate(self)
        #endif

        // REQUIRED Initialization
        tealium = Tealium(config: config) { response in
//        self.tealium?.persistentData()?.add(data: ["testPersistentKey": "testPersistentValue"])
            
//        self.tealium?.persistentData()?.deleteData(forKeys: ["user_name", "testPersistentKey", "newPersistentKey"])
            
//                            self.tealium?.persistentData()?.add(data: ["newPersistentKey": "testPersistentValue"])
//                            self.tealium?.volatileData()?.add(data: ["testVolatileKey": "testVolatileValue"])
        }
    }

    func lifecycleSleep() {
        Tealium.lifecycleListeners.sleep()
    }
    
    func lifecycleWake() {
        Tealium.lifecycleListeners.wake()
    }
    
    func track(title: String, data: [String: Any]?) {
        tealium?.track(title: title,
                       data: data,
                       completion: { (success, info, error) in
                        // Optional post processing
                        if self.enableHelperLogs == false {
                            return
                        }
        })
    }

    func trackView(title: String, data: [String: Any]?) {
        tealium?.trackView(title: title,
                       data: data,
                       completion: { (success, info, error) in
                        // Optional post processing
                        if self.enableHelperLogs == false {
                            return
                        }
        })

    }

}

extension TealiumWatchHelper: TealiumVisitorServiceDelegate {
    
    func didUpdate(visitorProfile: TealiumVisitorProfile) {
        if let json = try? JSONEncoder().encode(visitorProfile), let string = String(data: json, encoding: .utf8) {
            print(string)
        }
    }
    
}
