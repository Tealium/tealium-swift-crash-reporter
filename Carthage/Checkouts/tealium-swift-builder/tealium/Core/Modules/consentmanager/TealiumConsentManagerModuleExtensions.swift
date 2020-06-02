//
//  TealiumConsentManagerModuleExtensions.swift
//  tealium-swift
//
//  Created by Craig Rouse on 20/03/2019.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//

import Foundation

extension TealiumConsentManagerModule: TealiumConsentManagerDelegate {

    /// Called when the consent manager will drop a request (user not consented)￼.
    ///
    /// - Parameter request: `TealiumTrackRequest`
    func willDropTrackingCall(_ request: TealiumTrackRequest) {

    }

    /// Called when the consent manager will queue a request (user consent state not determined)￼.
    ///
    /// - Parameter request: `TealiumTrackRequest`
    func willQueueTrackingCall(_ request: TealiumTrackRequest) {

    }

    /// Called when the consent manager will send a request (user has consented)￼.
    ///
    /// - Parameter request: `TealiumTrackRequest`
    func willSendTrackingCall(_ request: TealiumTrackRequest) {

    }

    /// Called when the user has changed their consent status￼.
    ///
    /// - Parameter status: `TealiumConsentStatus`
    func consentStatusChanged(_ status: TealiumConsentStatus) {
        switch status {
        case .notConsented:
            print("should purge queue")
        case .consented:
//            print("should release queue")
            self.delegate?.requestReleaseQueue(reason: "Consent status changed to .consented")
        default:
            return
        }
    }

    /// Called when the user consented to tracking.
    func userConsentedToTracking() {

    }

    /// Called when the user declined tracking consent.
    func userOptedOutOfTracking() {

    }

    /// Called when the user changed their consent category choices￼.
    ///
    /// - Parameter categories: `[TealiumConsentCategories]` containing the new list of consent categories selected by the user
    func userChangedConsentCategories(categories: [TealiumConsentCategories]) {

    }
}

// public interface for consent manager
public extension Tealium {

    var consentManager: TealiumConsentManager? {
        let module = zz_internal_modulesManager?.collectors.filter {
            $0 is TealiumConsentManagerModule
        }.first
        return (module as? TealiumConsentManagerModule)?.consentManager
    }
    
//    /// - Returns: `TealiumConsentManager` instance
//    var consentManager: TealiumConsentManager? {
//        guard let module = modulesManager?.modules.filter({ $0 is TealiumConsentManagerModule })[0] as? TealiumConsentManagerModule else {
//            return nil
//        }
//        return module.consentManager
//    }
}

public extension TealiumConfig {
    
    var consentManagerDelegate: TealiumConsentManagerDelegate? {
        get {
            optionalData[TealiumConsentConstants.consentManagerDelegate] as? TealiumConsentManagerDelegate
        }

        set {
            optionalData[TealiumConsentConstants.consentManagerDelegate] = newValue
        }
    }
    
}
