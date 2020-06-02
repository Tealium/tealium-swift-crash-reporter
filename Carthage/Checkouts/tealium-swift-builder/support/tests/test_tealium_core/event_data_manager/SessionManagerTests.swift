//
//  SessionManagerTests.swift
//  TealiumCoreTests
//
//  Created by Christina S on 5/5/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

@testable import TealiumCore
import XCTest

class SessionManagerTests: XCTestCase {

    var config: TealiumConfig!
    var eventDataManager: EventDataManager!
    var mockSessionStarter = MockTealiumSessionStarter()
    var mockURLSession = MockURLSessionSessionStarter()
    var mockDiskStorage = MockEventDataDiskStorage()
    var timeTraveler = TimeTraveler()
    var lastTrackDate: Date!
    var numberOfTracks: Int!

    override func setUpWithError() throws {
        config = TealiumConfig(account: "testAccount", profile: "testProfile", environment: "testEnvironment")
        eventDataManager = EventDataManager(config: config, diskStorage: mockDiskStorage, sessionStarter: mockSessionStarter)
    }

    override func tearDownWithError() throws {
        eventDataManager.numberOfTracksBacking = 0
    }

    func testLastTrackDateNilIncrementsNumberOfTracksBackingAndSetsLastTrackDate() {
        eventDataManager.lastTrackDate = nil
        eventDataManager.numberOfTracks = 0
        XCTAssertEqual(eventDataManager.numberOfTracksBacking, 2)
        XCTAssertNotNil(eventDataManager.lastTrackDate)
    }

    func testTwoTracksInSecondsBetweenTracksStartsNewSession() {
        eventDataManager.tagManagementIsEnabled = true
        eventDataManager.shouldTriggerSessionRequest = true
        eventDataManager.lastTrackDate = timeTraveler.travel(by: 20)
        eventDataManager.numberOfTracks += 1
        XCTAssertEqual(mockSessionStarter.sessionRequestCount, 1)
        XCTAssertFalse(eventDataManager.shouldTriggerSessionRequest)
        XCTAssertEqual(eventDataManager.numberOfTracksBacking, 0)
        XCTAssertNil(eventDataManager.lastTrackDate)

    }

    func testTwoTracksGreaterThanSecondsBetweenTracksSetsNumberOfTracksBackingToZero() {
        eventDataManager.lastTrackDate = timeTraveler.travel(by: 40)
        eventDataManager.numberOfTracks += 1
        XCTAssertEqual(mockSessionStarter.sessionRequestCount, 0)
        XCTAssertFalse(eventDataManager.shouldTriggerSessionRequest)
        XCTAssertEqual(eventDataManager.numberOfTracksBacking, 0)
    }

    func testSessionIdReturnsFromPersistentStorage() {
        let sessionId = eventDataManager.sessionId
        XCTAssertNotNil(sessionId)
    }

    func testSessionIdSavesToPersistentStorage() {
        eventDataManager.sessionId = "test123abc"
        let eventDataItem = EventDataItem(key: "tealium_session_id", value: "test123abc", expires: .distantFuture)
        let retrieved = mockDiskStorage.retrieve(as: EventData.self)
        XCTAssertTrue(((retrieved?.contains(eventDataItem)) != nil))
    }

    func testRefreshSessionData() {
        eventDataManager.refreshSessionData()
        XCTAssertEqual(eventDataManager.sessionData.count, 1)
        XCTAssertNotNil(eventDataManager.sessionId)
        XCTAssertTrue(eventDataManager.shouldTriggerSessionRequest)
    }

    func testSessionRefreshWhenSessionIdNil() {
        eventDataManager.sessionId = nil
        eventDataManager.lastTrackDate = nil
        XCTAssertEqual(eventDataManager.numberOfTracksBacking, 1)
        XCTAssertTrue(eventDataManager.shouldTriggerSessionRequest)
    }

    func testSessionRefreshWhenSessionIdNotNil() {
        eventDataManager.sessionRefresh()
        XCTAssertNotNil(eventDataManager.allEventData["tealium_session_id"] as! String)
    }

    func testStartNewSessionWhenTagManageMentEnabledTriggerNewSessionFalse() {
        eventDataManager.tagManagementIsEnabled = true
        eventDataManager.shouldTriggerSessionRequest = false
        eventDataManager.startNewSession(with: mockSessionStarter)
        XCTAssertEqual(mockSessionStarter.sessionRequestCount, 0)
    }

    func testStartNewSessionWhenTagManageMentNotEnabledTriggerNewSessionTrue() {
        eventDataManager.tagManagementIsEnabled = false
        eventDataManager.shouldTriggerSessionRequest = true
        eventDataManager.startNewSession(with: mockSessionStarter)
        XCTAssertEqual(mockSessionStarter.sessionRequestCount, 0)
    }

    func testStartNewSessionWhenTagManageMentEnabledTriggerNewSessionTrue() {
        eventDataManager.tagManagementIsEnabled = true
        eventDataManager.shouldTriggerSessionRequest = true
        eventDataManager.startNewSession(with: mockSessionStarter)
        XCTAssertEqual(mockSessionStarter.sessionRequestCount, 1)
    }

}
