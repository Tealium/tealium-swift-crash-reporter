//
//  EventDataTests.swift
//  TealiumCoreTests
//
//  Created by Christina S on 5/4/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

@testable import TealiumCore
import XCTest

class EventDataTests: XCTestCase {

    var mockEventDataItem: EventDataItem!
    var eventData: EventData!

    override func setUpWithError() throws {
        mockEventDataItem = EventDataItem(key: "itemOne", value: "test1", expires: .distantFuture)
        eventData = Set(arrayLiteral: mockEventDataItem)
    }

    override func tearDownWithError() throws {
    }

    func testInsertNewSingle() {
        eventData.insertNew(key: "itemTwo", value: "test2", expires: .distantFuture)
        XCTAssertEqual(eventData.count, 2)
        XCTAssertTrue(eventData.isSubset(of: [mockEventDataItem, EventDataItem(key: "itemTwo", value: "test2", expires: .distantFuture)]))
    }

    func testInsertNewSingleExpires() {
        eventData = EventData()
        eventData.insertNew(key: "itemOne", value: "test1", expires: .distantPast)
        let eventDataExpired = eventData.removeExpired()
        XCTAssertEqual(eventDataExpired.count, 0)
    }

    func testInsertNewMulti() {
        let multi = ["itemTwo": "test2", "itemThree": "test3"]
        eventData.insertNew(from: multi, expires: .distantFuture)
        XCTAssertEqual(eventData.count, 3)
        XCTAssertTrue(eventData.isSubset(of: [mockEventDataItem, EventDataItem(key: "itemTwo", value: "test2", expires: .distantFuture), EventDataItem(key: "itemThree", value: "test3", expires: .distantFuture)]))
    }

    func testInsertNewMultiExpires() {
        eventData = EventData()
        let multi = ["itemTwo": "test2", "itemThree": "test3"]
        eventData.insertNew(from: multi, expires: .distantPast)
        let eventDataExpired = eventData.removeExpired()
        XCTAssertEqual(eventDataExpired.count, 0)
    }

    func testRemove() {
        eventData.remove(key: "itemOne")
        XCTAssertEqual(eventData.count, 0)
    }

    func testGetAllData() {
        let multi = ["itemTwo": "test2", "itemThree": "test3"]
        eventData.insertNew(from: multi, expires: .distantFuture)
        let expected: [String: Any] = ["itemOne": "test1", "itemTwo": "test2", "itemThree": "test3"]
        let actual = eventData.allData
        XCTAssert(NSDictionary(dictionary: actual).isEqual(to: expected))
    }

}
