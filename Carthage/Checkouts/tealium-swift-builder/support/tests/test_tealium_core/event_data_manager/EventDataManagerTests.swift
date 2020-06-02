//
//  EventDataManagerTests.swift
//  TealiumCoreTests
//
//  Created by Christina S on 5/4/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

@testable import TealiumCore
import XCTest

class EventDataManagerTests: XCTestCase {

    var config: TealiumConfig!
    var eventDataManager: EventDataManager!
    var mockDiskStorage: TealiumDiskStorageProtocol!
    var mockSessionStarter: SessionStarter!

    override func setUpWithError() throws {
        config = TealiumConfig(account: "testAccount", profile: "testProfile", environment: "testEnvironment", datasource: "testDatasource")
        mockDiskStorage = MockEventDataDiskStorage()
        mockSessionStarter = SessionStarter(config: TestTealiumHelper().getConfig(), urlSession: MockURLSessionSessionStarter())
        eventDataManager = EventDataManager(config: TestTealiumHelper().getConfig(), diskStorage: mockDiskStorage, sessionStarter: mockSessionStarter)
    }

    override func tearDownWithError() throws {
    }

    func testInitSetsStaticData() {
        let expected: [String: Any] = ["timestamp": "2020-05-04T23:05:51Z",
                                       "timestamp_unix": "1588633551",
                                       "tealium_session_id": "1588633455745",
                                       "tealium_timestamp_epoch": "1588633551",
                                       "timestamp_offset": "-7",
                                       "tealium_account": "testAccount",
                                       "tealium_environment": "testEnvironment",
                                       "tealium_library_version": "1.10.0",
                                       "tealium_profile": "testProfile",
                                       "timestamp_local": "2020-05-04T16:05:51",
                                       "tealium_library_name": "swift",
                                       "timestamp_unix_milliseconds": "1588633551183",
                                       "tealium_random": "4", "singleDataItemKey1": "singleDataItemValue1", "singleDataItemKey2": "singleDataItemValue2"]//, "tealium_datasource": "testDatasource"]
        let actual = eventDataManager.allEventData
        XCTAssertEqual(actual.count, expected.count)
        XCTAssertEqual(actual.keys, expected.keys)
        XCTAssertEqual(actual[TealiumKey.account] as! String, "testAccount")
        XCTAssertEqual(actual[TealiumKey.profile] as! String, "testProfile")
        XCTAssertEqual(actual[TealiumKey.environment] as! String, "testEnvironment")
        //        XCTAssertEqual(actual[TealiumKey.dataSource] as! String, "testDatasource")
        XCTAssertEqual(actual[TealiumKey.libraryName] as! String, "swift")

    }

    func testCurrentTimeStamps() {
        let timeStamps = eventDataManager.currentTimeStamps
        XCTAssertEqual(timeStamps.count, 5)
        let expectedKeys = [TealiumKey.timestampEpoch, TealiumKey.timestamp, TealiumKey.timestampLocal, TealiumKey.timestampUnixMilliseconds, TealiumKey.timestampUnix]
        let keys = timeStamps.map { $0.key }
        XCTAssertEqual(keys.sorted(), expectedKeys.sorted())
    }

    func testAddSessionData() {
        let sessionData: [String: Any] = ["hello": "session"]
        let eventDataItem = EventDataItem(key: "hello", value: "session", expires: .distantFuture)
        eventDataManager.add(data: sessionData, expiration: .session)
        XCTAssertNotNil(eventDataManager.allEventData["hello"])
        XCTAssertEqual(eventDataManager.allEventData["hello"] as! String, "session")
        let retrieved = mockDiskStorage.retrieve(as: EventData.self)
        XCTAssertTrue(((retrieved?.contains(eventDataItem)) != nil))
    }

    func testAddRestartData() {
        let restartData: [String: Any] = ["hello": "restart"]
        let eventDataItem = EventDataItem(key: "hello", value: "restart", expires: .init(timeIntervalSinceNow: 60 * 60 * 12))
        eventDataManager.add(data: restartData, expiration: .untilRestart)
        XCTAssertNotNil(eventDataManager.allEventData["hello"])
        XCTAssertEqual(eventDataManager.allEventData["hello"] as! String, "restart")
        let retrieved = mockDiskStorage.retrieve(as: EventData.self)
        XCTAssertTrue(((retrieved?.contains(eventDataItem)) != nil))
    }

    func testAddForeverData() {
        let foreverData: [String: Any] = ["hello": "forever"]
        let eventDataItem = EventDataItem(key: "hello", value: "forever", expires: .distantFuture)
        eventDataManager.add(data: foreverData, expiration: .forever)
        XCTAssertNotNil(eventDataManager.allEventData["hello"])
        XCTAssertEqual(eventDataManager.allEventData["hello"] as! String, "forever")
        let retrieved = mockDiskStorage.retrieve(as: EventData.self)
        XCTAssertTrue(((retrieved?.contains(eventDataItem)) != nil))
    }

    func testCurrentTimeStampsExist() {
        var timeStamps = eventDataManager.currentTimeStamps
        timeStamps[TealiumKey.timestampOffset] = Date().timestampInSeconds
        XCTAssertTrue(eventDataManager.currentTimestampsExist(timeStamps))
    }

    func testCurrentTimeStampsDontExist() {
        XCTAssertFalse(eventDataManager.currentTimestampsExist([String: Any]()))
    }

    func testDeleteForKeys() {
        eventDataManager.delete(forKeys: ["singleDataItemKey1", "singleDataItemKey2"])
        let retrieved = mockDiskStorage.retrieve(as: EventData.self)
        XCTAssertEqual(retrieved?.count, 1)
    }

    func testDeleteForKey() {
        eventDataManager.delete(forKey: "singleDataItemKey1")
        let retrieved = mockDiskStorage.retrieve(as: EventData.self)
        XCTAssertEqual(retrieved?.count, 2)
    }

    func testDeleteAll() {
        eventDataManager.deleteAll()
        let retrieved = mockDiskStorage.retrieve(as: EventData.self)
        XCTAssertEqual(retrieved?.count, 0)
    }

}
