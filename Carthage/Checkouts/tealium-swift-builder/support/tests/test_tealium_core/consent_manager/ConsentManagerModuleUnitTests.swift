//
//  ConsentManagerModuleUnitTests.swift
//  tealium-swift
//
//  Created by Craig Rouse on 03/05/18.
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

import Foundation
@testable import TealiumCore
import XCTest

class ConsentManagerModuleUnitTests: XCTestCase {

    var config: TealiumConfig!
    var track: TealiumTrackRequest!
    var module: TealiumConsentManagerModule!

    override func setUp() {
        config = TealiumConfig(account: "testAccount", profile: "testProfile", environment: "testEnvironment")
        config.enableConsentManager = true
    }
    
    func testConsentManagerIsDisabledAutomatically() {
        let config2 = TealiumConfig(account: "testAccount", profile: "testProfile", environment: "testEnvironment")
        let teal = Tealium(config: config2)
        XCTAssertNil(teal.consentManager)
    }

    func testShouldQueueIsBatchTrackRequest() {
        track = TealiumTrackRequest(data: ["test": "track"])
        let batchTrack = TealiumBatchTrackRequest(trackRequests: [track, track, track], completion: nil)
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        let queue = module.shouldQueue(request: batchTrack)
        XCTAssertTrue(queue.0)
        XCTAssertTrue(queue.1?["queue_reason"] as? String == "batching_enabled", "Consent Manager Module: \(#function) - Track call contained unexpected value")
    }

    func testShouldQueueAllowAuditingEvents() {
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        let auditingEvents = [
            TealiumConsentConstants.consentPartialEventName,
            TealiumConsentConstants.consentGrantedEventName,
            TealiumConsentConstants.consentDeclinedEventName,
            TealiumKey.updateConsentCookieEventName
        ]
        auditingEvents.forEach {
            track = TealiumTrackRequest(data: [TealiumKey.event: $0])
            let queue = module.shouldQueue(request: track)
            XCTAssertFalse(queue.0)
            XCTAssertNil(queue.1)
        }
    }

    func testShouldQueueTrackingStatusTrackingQueued() {
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        module.consentManager?.resetUserConsentPreferences()
        track = TealiumTrackRequest(data: ["test": "track"])
        let queue = module.shouldQueue(request: track)
        XCTAssertTrue(queue.0)
        XCTAssertTrue(queue.1?["queue_reason"] as? String == "consentmanager", "Consent Manager Module: \(#function) - Track call contained unexpected value")
        XCTAssertTrue(queue.1?["tracking_consented"] as? String == "unknown", "Consent Manager Module: \(#function) - Track call contained unexpected value")
        guard let categories = queue.1?["consent_categories"] as? [String] else {
            XCTFail("Consent categories should be present in dictionary")
            return
        }
        XCTAssertEqual(categories.count, 0)
    }

    func testShouldQueueTrackingStatusTrackingAllowed() {
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        module.consentManager?.setUserConsentStatus(.consented)
        module.consentManager?.setUserConsentCategories([.affiliates, .analytics, .bigData])
        track = TealiumTrackRequest(data: ["test": "track"])
        let queue = module.shouldQueue(request: track)
        XCTAssertFalse(queue.0)
        XCTAssertTrue(queue.1?["tracking_consented"] as? String == "consented", "Consent Manager Module: \(#function) - Track call contained unexpected value")
        guard let categories = queue.1?["consent_categories"] as? [String] else {
            XCTFail("Consent categories should be present in dictionary")
            return
        }
        XCTAssertEqual(categories.count, 3)
    }

    func testShouldQueueTrackingStatusTrackingForbidden() {
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        module.consentManager?.setUserConsentStatus(.notConsented)
        track = TealiumTrackRequest(data: ["test": "track"])
        let queue = module.shouldQueue(request: track)
        XCTAssertFalse(queue.0)
        XCTAssertTrue(queue.1?["tracking_consented"] as? String == "notConsented", "Consent Manager Module: \(#function) - Track call contained unexpected value")
        guard let categories = queue.1?["consent_categories"] as? [String] else {
            XCTFail("Consent categories should be present in dictionary")
            return
        }
        XCTAssertEqual(categories.count, 0)
    }

    func testShouldDropWhenTrackingForbidden() {
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        module.consentManager?.setUserConsentStatus(.notConsented)
        track = TealiumTrackRequest(data: ["test": "track"])
        let drop = module.shouldDrop(request: track)
        XCTAssertTrue(drop)
    }

    func testShouldNotDropWhenTrackingAllowed() {
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        module.consentManager?.setUserConsentStatus(.consented)
        track = TealiumTrackRequest(data: ["test": "track"])
        let drop = module.shouldDrop(request: track)
        XCTAssertFalse(drop)
    }

    func testShouldPurgeWhenTrackingForbidden() {
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        module.consentManager?.setUserConsentStatus(.notConsented)
        track = TealiumTrackRequest(data: ["test": "track"])
        let purge = module.shouldPurge(request: track)
        XCTAssertTrue(purge)
    }

    func testShouldNotPurgeWhenTrackingAllowed() {
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        module.consentManager?.setUserConsentStatus(.consented)
        track = TealiumTrackRequest(data: ["test": "track"])
        let purge = module.shouldPurge(request: track)
        XCTAssertFalse(purge)
    }

    func testAddConsentDataToTrackWhenConsented() {
        config.initialUserConsentStatus = .consented
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        let expected: [String: Any] = [
            TealiumConsentConstants.trackingConsentedKey: "consented",
            TealiumConsentConstants.consentCategoriesKey: ["analytics",
                                                           "affiliates",
                                                           "display_ads",
                                                           "email",
                                                           "personalization",
                                                           "search",
                                                           "social",
                                                           "big_data",
                                                           "mobile",
                                                           "engagement",
                                                           "monitoring",
                                                           "crm",
                                                           "cdp",
                                                           "cookiematch",
                                                           "misc"],
            "test": "track"
        ]
        track = TealiumTrackRequest(data: ["test": "track"])
        var trackWithConsentData = module.addConsentDataToTrack(track).trackDictionary
        XCTAssertNotNil(trackWithConsentData[TealiumKey.requestUUID])
        trackWithConsentData[TealiumKey.requestUUID] = nil
        XCTAssertTrue(NSDictionary(dictionary: expected).isEqual(to: trackWithConsentData))
    }

    func testAddConsentDataToTrackWhenNotConsented() {
        config.initialUserConsentStatus = .notConsented
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        let expected: [String: Any] = [
            TealiumConsentConstants.trackingConsentedKey: "notConsented",
            TealiumConsentConstants.consentCategoriesKey: [],
            "test": "track"
        ]
        track = TealiumTrackRequest(data: ["test": "track"])
        var trackWithConsentData = module.addConsentDataToTrack(track).trackDictionary
        XCTAssertNotNil(trackWithConsentData[TealiumKey.requestUUID])
        trackWithConsentData[TealiumKey.requestUUID] = nil
        XCTAssertTrue(NSDictionary(dictionary: expected).isEqual(to: trackWithConsentData))
    }

    func testAddConsentDataToTrackWhenResetConsentStatus() {
        config.initialUserConsentStatus = .consented
        module = TealiumConsentManagerModule(config: config, delegate: self, diskStorage: ConsentMockDiskStorage(), completion: { _ in })
        module.consentManager?.resetUserConsentPreferences()
        let expected: [String: Any] = [
            TealiumConsentConstants.trackingConsentedKey: "unknown",
            TealiumConsentConstants.consentCategoriesKey: [],
            "test": "track"
        ]
        track = TealiumTrackRequest(data: ["test": "track"])
        var trackWithConsentData = module.addConsentDataToTrack(track).trackDictionary
        XCTAssertNotNil(trackWithConsentData[TealiumKey.requestUUID])
        trackWithConsentData[TealiumKey.requestUUID] = nil
        XCTAssertTrue(NSDictionary(dictionary: expected).isEqual(to: trackWithConsentData))
    }

}

extension ConsentManagerModuleUnitTests: TealiumModuleDelegate {
    func requestReleaseQueue(reason: String) {
        
    }
    
    func requestTrack(_ track: TealiumTrackRequest) {

    }
}
