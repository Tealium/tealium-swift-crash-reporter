//
//  TealiumVolatileDataTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 11/17/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

@testable import TealiumCore
import XCTest

class TealiumVolatileDataTests: XCTestCase {

    var volatileData: TealiumVolatileData?
    var mockEventDataMgr = MockEventDataManager()
    let testVolatileData = ["key": "value",
                                        "anotherKey": "anotherValue"]

    override func setUp() {
        volatileData = TealiumVolatileData(eventDataManager: mockEventDataMgr)
    }
    
    func testDicationary() {
        let dict = volatileData?.dictionary
        XCTAssert(NSDictionary(dictionary: ["all": "sessiondata"]).isEqual(to: dict!))
    }

    func testAddDictionary() {
        volatileData?.add(data: testVolatileData)
        XCTAssertEqual(mockEventDataMgr.addMultiCount, 1)
    }
    
    func testAddSingleValue() {
        volatileData?.add(value: "world", forKey: "hello")
        XCTAssertEqual(mockEventDataMgr.addSingleCount, 1)
    }
    
    func testDeleteSingleValue() {
        volatileData?.delete(for: "hello")
        XCTAssertEqual(mockEventDataMgr.deleteSingleCount, 1)
    }
    
    func testDeleteMultipleKeys() {
        volatileData?.deleteData(forKeys: ["key", "anotherKey"])
        XCTAssertEqual(mockEventDataMgr.deleteMultiCount, 1)
    }
    
    func testDeleteAll() {
        volatileData?.deleteAllData()
        XCTAssertEqual(mockEventDataMgr.sessionDataBacking.count, 0)
    }

}
