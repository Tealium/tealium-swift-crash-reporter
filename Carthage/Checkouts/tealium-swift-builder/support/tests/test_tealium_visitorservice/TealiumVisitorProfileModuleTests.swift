//
//  TealiumVisitorServiceModuleTests.swift
//  tealium-swift
//
//  Created by Christina Sund on 6/17/19.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//

import Foundation
@testable import TealiumCore
@testable import TealiumVisitorService
import XCTest

class TealiumVisitorServiceModuleTests: XCTestCase {

    var visitorServiceManager: TealiumVisitorServiceManager?
    var mockDiskStorage: MockTealiumDiskStorage!
    var mockVisitorServiceManager = MockTealiumVisitorServiceManager()
    var config: TealiumConfig!
    var expectations = [XCTestExpectation]()
    let waiter = XCTWaiter()

    override func setUp() {
        super.setUp()
        config = TealiumConfig(account: "testAccount", profile: "testProfile", environment: "testEnv")
        mockDiskStorage = MockTealiumDiskStorage()
        visitorServiceManager = TealiumVisitorServiceManager(config: config, delegate: nil, diskStorage: mockDiskStorage)
        visitorServiceManager?.visitorId = "test"
    }

    func testRequestVisitorProfileRunWhenFirstEventSentTrue() {
        self.expectations.append(expectation(description: "testRequestVisitorProfileRunWhenFirstEventSentTrue"))
        let module = TealiumVisitorServiceModule(config: config, delegate: self, diskStorage: mockDiskStorage, visitorServiceManager: mockVisitorServiceManager)
        module.firstEventSent = true
        module.retrieveProfile(visitorId: "test")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(1, self.mockVisitorServiceManager.requestVisitorProfileCount)
        }
        waiter.wait(for: expectations, timeout: 3.0)
    }

    func testStartProfileUpdatesRunWhenFirstEventSentFalse() {
        self.expectations.append(expectation(description: "testStartProfileUpdatesRunWhenFirstEventSentFalse"))
        let module = TealiumVisitorServiceModule(config: config, delegate: self, diskStorage: mockDiskStorage, visitorServiceManager: mockVisitorServiceManager)
        module.firstEventSent = false
        module.retrieveProfile(visitorId: "test")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(1, self.mockVisitorServiceManager.startProfileUpdatesCount)
        }
        waiter.wait(for: expectations, timeout: 3.0)
    }

    func testBatchTrackRetreiveProfileExecuted() {
        expectations.append(expectation(description: "testBatchTrackRetreiveProfileExecuted"))
        let module = TealiumVisitorServiceModule(config: config, delegate: self, diskStorage: mockDiskStorage, visitorServiceManager: mockVisitorServiceManager)
        module.firstEventSent = true
        let trackRequest = TealiumTrackRequest(data: ["hello": "world", "tealium_visitor_id": "test"], completion: nil)
        let batchTrackRequest = TealiumBatchTrackRequest(trackRequests: [trackRequest], completion: nil)
        module.willTrack(request: batchTrackRequest)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(1, self.mockVisitorServiceManager.requestVisitorProfileCount)
        }
        waiter.wait(for: expectations, timeout: 3.0)
    }

    func testTrackRetreiveProfileExecuted() {
        expectations.append(expectation(description: "testTrackRetreiveProfileExecuted"))
        let module = TealiumVisitorServiceModule(config: config, delegate: self, diskStorage: mockDiskStorage, visitorServiceManager: mockVisitorServiceManager)
        module.firstEventSent = true
        let trackRequest = TealiumTrackRequest(data: ["hello": "world", "tealium_visitor_id": "test"], completion: nil)
        module.willTrack(request: trackRequest)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            XCTAssertEqual(1, self.mockVisitorServiceManager.requestVisitorProfileCount)
        }
        waiter.wait(for: expectations, timeout: 3.0)
    }

}

extension TealiumVisitorServiceModuleTests: TealiumModuleDelegate {
    func requestReleaseQueue(reason: String) {

    }

    func requestTrack(_ track: TealiumTrackRequest) {

    }

}
