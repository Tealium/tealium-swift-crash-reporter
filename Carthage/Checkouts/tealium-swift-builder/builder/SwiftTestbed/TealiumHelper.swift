//
//  TealiumHelper.swift
//  SwiftTestbed
//
//  Created by Jason Koo on 11/22/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

import Foundation
import TealiumCore
//import TealiumCrash2
import TealiumCollect
import TealiumTagManagement
import TealiumAttribution
//import TealiumRemoteCommands
import TealiumVisitorService
import TealiumLifecycle
import TealiumLocation

extension String: Error {}

/// Example of a shared helper to handle all 3rd party tracking services. This
/// paradigm is recommended to reduce burden of future code updates for external services
/// in general.
/// Note: TealiumHelper class inherits from NSObject to allow @objc annotations and Objective-C interop.
/// If you don't need this, you may omit @objc annotations and NSObject inheritance.
class TealiumHelper: NSObject {

    static let shared = TealiumHelper()
    var tealium: Tealium?
    var enableHelperLogs = true
    var traceId = "04136"
    var logger: TealiumLoggerProtocol?

    override private init () {

    }

    func start() {
        // REQUIRED Config object for lib
        let config = TealiumConfig(account: "tealiummobile",
                                   profile: "demo",
                                   environment: "dev",
                                   datasource: "test12",
                                   optionalData: nil)
        config.connectivityRefreshInterval = 5
        config.loggerType = .os 
//        config.logLevel = .info
        config.consentLoggingEnabled = true
        config.dispatchListeners = [self]
        config.dispatchValidators = [self]
        config.searchAdsEnabled = true
        config.enableConsentManager = false
        config.initialUserConsentStatus = .consented
//        config.shouldAddCookieObserver = false
        config.shouldUseRemotePublishSettings = false
        // config.batchSize = 5
        // config.dispatchAfter = 5
        // config.dispatchQueueLimit = 200
        config.batchingEnabled = false
        // config.visitorServiceRefreshInterval = 0
        // config.visitorServiceOverrideProfile = "main"
        config.memoryReportingEnabled = true

        #if AUTOTRACKING
//        print("*** TealiumHelper: Autotracking enabled.")
        #else
        // OPTIONALLY disable a particular module by name
        
//        let list = TealiumModulesList(isWhitelist: false,
//                                      moduleNames: [.autotracking, .consentmanager])
//        config.modulesList = list
        config.consentManagerDelegate = self
        config.diskStorageEnabled = true
        config.visitorServiceDelegate = self
        config.remoteAPIEnabled = false
//        config.logLevel = .verbose
        config.logLevel = .info
        config.loggerType = .print
        config.shouldCollectTealiumData = true
        config.memoryReportingEnabled = true
        config.batterySaverEnabled = true
        logger = config.logger
//        config.geofenceUrl = "https://tags.tiqcdn.com/dle/tealiummobile/location/geofences.json"
        #endif
//        #if os(iOS)
//
//        let remoteCommand = TealiumRemoteCommand(commandId: "hello",
//                                                 description: "test") { response in
//                                                    if TealiumHelper.shared.enableHelperLogs {
////                                                        print("*** TealiumHelper: Remote Command Executed: response:\(response)")
//                                                    }
//                                                    let dict = ["hello":"from helper"]
//                                                    // set some JSON response data to be passed back to the webview
//                                                    let myJson = try? JSONSerialization.data(withJSONObject: dict, options: [])
//                                                    response.data = myJson
//        }
//        config.addRemoteCommand(remoteCommand)
//        #endif
        
        // REQUIRED Initialization
//        tealium?.logger()
        tealium = Tealium(config: config) { [weak self] response in
            guard let self = self,
                let teal = self.tealium else {
                return
                
            }

            self.track(title: "init", data: nil)

            let persitence = teal.persistentData()
            let sessionPersistence = teal.volatileData()
            let dataManager = teal.eventDataManager
            teal.consentManager?.setUserConsentStatus(.consented)
            teal.consentManager?.addConsentDelegate(self)
            dataManager.add(key: "myvarforever", value: 123456, expiration: .forever)

            persitence.add(data: ["some_key1": "some_val1"], expiration: .session)

            persitence.add(data: ["some_key_forever":"some_val_forever"]) // forever

             persitence.add(data: ["until": "restart"], expiration: .untilRestart)

            persitence.add(data: ["custom": "expire in 3 min"], expiration: .afterCustom((.minutes, 3)))

            persitence.deleteData(forKeys: ["myvarforever"])

            sessionPersistence.add(data: ["hello": "world"]) // session

            sessionPersistence.add(value: 123, forKey: "test") // session

            sessionPersistence.deleteData(forKeys: ["hello", "test"])

            persitence.add(value: "hello", forKey: "itsme", expiration: .afterCustom((.months, 1)))

            print("Volatile Data: \(String(describing: sessionPersistence.dictionary))")

            print("Persistent Data: \(String(describing: persitence.dictionary))")

        }
        tealium?.track(title: "hello")
        
    }
    
    func resetConsentPreferences() {
        tealium?.consentManager?.resetUserConsentPreferences()
    }
    
    
    func toggleConsentStatus() {
        if let consentStatus = tealium?.consentManager?.getUserConsentStatus() {
            switch consentStatus {
            case .consented:
                TealiumHelper.shared.tealium?.consentManager?.setUserConsentStatus(.notConsented)
            default:
                TealiumHelper.shared.tealium?.consentManager?.setUserConsentStatus(.consented)
            }
        }
    }
    
    
    func updateConsentPreferences() {
        let cats = ["analytics", "monitoring", "big_data", /*"mobile", "crm", "affiliates", "email", "search", */"engagement", "cdp"]
        var dict = [String: Any]()
        dict["consentStatus"] = "notConsented"
        dict["consentCategories"] = cats
        if let status = dict["consentStatus"] as? String {
            var tealiumConsentCategories = [TealiumConsentCategories]()
            let tealiumConsentStatus = (status == "consented") ? TealiumConsentStatus.consented : TealiumConsentStatus.notConsented
            if let categories = dict["consentCategories"] as? [String] {
                tealiumConsentCategories = TealiumConsentCategories.consentCategoriesStringArrayToEnum(categories)
            }
            self.tealium?.consentManager?.setUserConsentStatusWithCategories(status: tealiumConsentStatus, categories: tealiumConsentCategories)
        }
    }

    func track(title: String, data: [String: Any]?) {
//        tealium?.lifecycle()?.launch(at: Date())
//        tealium?.disable()
//        self.tealium = nil
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
//        self.start()
        tealium?.trackView(title: title,
                       data: data,
                       completion: { (success, info, error) in
                        // Optional post processing
                        if self.enableHelperLogs == false {
                            return
                        }
        })

    }
    
    func joinTrace(_ traceID: String) {
        self.tealium?.joinTrace(traceId: traceID)
    }

    func leaveTrace() {
        self.tealium?.leaveTrace()
    }
    
    func crash() {
        NSException.raise(NSExceptionName(rawValue: "Exception"), format: "This is a test exception", arguments: getVaList(["nil"]))
    }
}

extension TealiumHelper: TealiumVisitorServiceDelegate {
    func didUpdate(visitorProfile: TealiumVisitorProfile) {
        if let json = try? JSONEncoder().encode(visitorProfile), let string = String(data: json, encoding: .utf8) {
            if self.enableHelperLogs {
//                print(string)
            }
        }
    }

}

extension TealiumHelper: TealiumConsentManagerDelegate {
    
    func willDropTrackingCall(_ request: TealiumTrackRequest) {
        
    }
    
    func willQueueTrackingCall(_ request: TealiumTrackRequest) {
        
    }
    
    func willSendTrackingCall(_ request: TealiumTrackRequest) {
        
    }
    
    func consentStatusChanged(_ status: TealiumConsentStatus) {
        
    }
    
    func userConsentedToTracking() {
        
    }
    
    func userOptedOutOfTracking() {
        
    }
    
    func userChangedConsentCategories(categories: [TealiumConsentCategories]) {
        
    }
    
    
}
//
extension TealiumHelper: DispatchListener {
    public func willTrack(request: TealiumRequest) {
        print("helper - willtrack")
    }
}

extension TealiumHelper: DispatchValidator {
    var id: String {
        return "Helper"
    }

    func shouldQueue(request: TealiumRequest) -> (Bool, [String : Any]?) {
        (false, nil)
    }

    func shouldDrop(request: TealiumRequest) -> Bool {
        false
    }

    func shouldPurge(request: TealiumRequest) -> Bool {
        false
    }


}
