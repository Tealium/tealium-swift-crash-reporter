//
//  TealiumAutotrackingModuleTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 12/22/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

@testable import TealiumAutotracking
@testable import TealiumCore
import XCTest

class TealiumAutotrackingModuleTests: XCTestCase {

    var module: TealiumAutotrackingModule {
        let config = testTealiumConfig.copy
        return TealiumAutotrackingModule(config: config, delegate: self, diskStorage: nil) { _ in

        }
    }
    var expectationRequest: XCTestExpectation?
    var expectationShouldTrack: XCTestExpectation?
    var expectationDidComplete: XCTestExpectation?
    var requestProcess: TealiumRequest?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        expectationRequest = nil
        expectationDidComplete = nil
        expectationShouldTrack = nil
        requestProcess = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //
    //    func testEnableDisable() {
    //        XCTAssertTrue(module!.notificationsEnabled)
    //
    //        module!.disable(TealiumDisableRequest())
    //
    //        XCTAssertFalse(module!.notificationsEnabled)
    //    }
    //
    //    func testRequestNoObjectEventTrack() {
    //        // Should ignore requests from missing objects
    //
    //        let notification = Notification(name: Notification.Name(rawValue: "com.tealium.autotracking.event"),
    //                                        object: nil,
    //                                        userInfo: nil)
    //
    //        module.requestEventTrack(sender: notification)
    //
    //        XCTAssertTrue(requestProcess == nil, "Request process found when none should exists.")
    //    }
    //
    func testRequestEmptyEventTrack() {
        let module = self.module
        let testObject = TestObject()

        let notification = Notification(name: Notification.Name(rawValue: "com.tealium.autotracking.event"),
                                        object: testObject,
                                        userInfo: nil)

        expectationRequest = expectation(description: "emptyEventDetected")

        module.requestEventTrack(sender: notification)

        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertTrue(requestProcess != nil, "Request process missing.")

        let data: [String: Any] = ["tealium_event": "TestObject",
                                   "autotracked": "true"
        ]

        guard let process = requestProcess as? TealiumTrackRequest else {
            XCTFail("Process was unavailable or of wrong type: \(String(describing: requestProcess))")
            return
        }
        var receivedData = process.trackDictionary

        receivedData["request_uuid"] = nil

        XCTAssertTrue(receivedData == data, "Mismatch between data expected: \n \(data as AnyObject) and data received post processing: \n \(receivedData as AnyObject)")
    }

    func testRequestEventTrack() {
        let module = self.module
        let testObject = TestObject()

        let notification = Notification(name: Notification.Name(rawValue: "com.tealium.autotracking.event"),
                                        object: testObject,
                                        userInfo: nil)

        expectationRequest = expectation(description: "eventDetected")

        module.requestEventTrack(sender: notification)

        waitForExpectations(timeout: 1.0, handler: nil)

        // The request process should have been populated by the requestEventTrack call

        XCTAssertTrue(requestProcess != nil)

        let data: [String: Any] = ["tealium_event": "TestObject",
                                   "autotracked": "true"
        ]

        guard let request = requestProcess as? TealiumTrackRequest else {
            XCTFail("Process not of track type.")
            return
        }

        var receivedData = request.trackDictionary

        receivedData["request_uuid"] = nil

        XCTAssertTrue(receivedData == data, "Mismatch between data expected: \n \(data as AnyObject) and data received post processing: \n \(receivedData as AnyObject)")
    }

    func testRequestEventTrackDelegate() {
        let module = self.module
        module.delegate = self

        let testObject = TestObject()

        let notification = Notification(name: Notification.Name(rawValue: "com.tealium.autotracking.event"),
                                        object: testObject,
                                        userInfo: nil)

        expectationRequest = expectation(description: "NotificationBasedTrack")

        module.requestEventTrack(sender: notification)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testAddCustomData() {
        let module = self.module
        let testObject = TestObject()

        let customData = ["a": "b",
                          "c": "d"]

        TealiumAutotracking.addCustom(data: customData,
                                      toObject: testObject)

        let notification = Notification(name: Notification.Name(rawValue: "com.tealium.autotracking.event"),
                                        object: testObject,
                                        userInfo: nil)

        expectationRequest = expectation(description: "customDataRequest")

        module.requestEventTrack(sender: notification)

        waitForExpectations(timeout: 1.0, handler: nil)

        guard let request = requestProcess as? TealiumTrackRequest else {
            XCTFail("Request not a track type.")
            return
        }

        let receivedData = request.trackDictionary

        XCTAssertTrue(customData.contains(otherDictionary: receivedData), "Custom data: \(customData) missing from track payload: \(receivedData)")
    }

    func testRemoveCustomData() {
        let module = self.module
        let testObject = TestObject()

        let customData = ["a": "b",
                          "c": "d"]

        TealiumAutotracking.addCustom(data: customData,
                                      toObject: testObject)

        TealiumAutotracking.removeCustomData(fromObject: testObject)

        let notification = Notification(name: Notification.Name(rawValue: "com.tealium.autotracking.event"),
                                        object: testObject,
                                        userInfo: nil)

        expectationRequest = expectation(description: "customDataRequest")

        module.requestEventTrack(sender: notification)

        waitForExpectations(timeout: 1.0, handler: nil)

        guard let request = requestProcess as? TealiumTrackRequest else {
            XCTFail("Request of incorrect type.")
            return
        }
        let receivedData = request.trackDictionary

        XCTAssertFalse(receivedData.contains(otherDictionary: customData), "Custom data: \(customData) was unexpectedly found in track payload: \(receivedData)")
    }

    // Cannot unit test requestViewTrack

    // Cannot unit test swizzling

}

extension TealiumAutotrackingModuleTests: TealiumModuleDelegate {
    func requestTrack(_ track: TealiumTrackRequest) {
        // TODO: Info and error callback handling
        track.completion?(true, nil, nil)
        requestProcess = track
        expectationRequest?.fulfill()
    }

    func requestReleaseQueue(reason: String) {

    }
}

class TestObject: NSObject {

}
