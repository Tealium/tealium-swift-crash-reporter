//
//  TealiumPersistentDataTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 11/18/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

@testable import TealiumCore
import XCTest

class TealiumPersistentDataTests: XCTestCase {

    var persistentData: TealiumPersistentData?
    var mockEventDataMgr = MockEventDataManager()
    let testPersistentData = ["key": "value",
                                     "anotherKey": "anotherValue"]

    override func setUp() {
        persistentData = TealiumPersistentData(eventDataManager: mockEventDataMgr)
    }
    
    func testDicationary() {
        let dict = persistentData?.dictionary
        XCTAssert(NSDictionary(dictionary: ["all": "eventdata"]).isEqual(to: dict!))
    }

    func testAddDictionary() {
        persistentData?.add(data: testPersistentData)
        XCTAssertEqual(mockEventDataMgr.addMultiCount, 1)
    }
    
    func testAddSingleValue() {
        persistentData?.add(value: "world", forKey: "hello")
        XCTAssertEqual(mockEventDataMgr.addSingleCount, 1)
    }
    
    func testDeleteSingleValue() {
        persistentData?.delete(forKey: "hello")
        XCTAssertEqual(mockEventDataMgr.deleteSingleCount, 1)
    }
    
    func testDeleteMultipleKeys() {
        persistentData?.deleteData(forKeys: ["key", "anotherKey"])
        XCTAssertEqual(mockEventDataMgr.deleteMultiCount, 1)
    }
    
    func testDeleteAll() {
        persistentData?.deleteAllData()
        XCTAssertEqual(mockEventDataMgr.deleteAllCount, 1)
    }
}
