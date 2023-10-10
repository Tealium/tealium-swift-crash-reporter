//
//  CrashModuleTests.swift
//  TealiumCrashModule
//
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

import TealiumCore
@testable import TealiumCrashModule
import XCTest

class CrashModuleTests: XCTestCase {

    var crashModule: CrashModule!
    var context: TealiumContext!
    var mockCrashReporter: MockTealiumCrashReporter!
    var onRequestTrack: ((TealiumTrackRequest) -> Void)?
    
    override func setUp() {
        super.setUp()
        let config = TealiumConfig(account: "TestAccount", profile: "TestProfile", environment: "TestEnvironment")
        let tealium = Tealium(config: config)
        context = TealiumContext(config: config, dataLayer: MockDataLayer(), tealium: tealium)
        mockCrashReporter = MockTealiumCrashReporter()
        crashModule = CrashModule(context: context,
                                  delegate: self,
                                  diskStorage: nil,
                                  crashReporter: mockCrashReporter)
    }

    override func tearDown() {
        crashModule = nil
        context = nil
        super.tearDown()
    }

    func testDataFinishesWithNoResponseWhenNoPendingCrashReport() {
        XCTAssertEqual(0, mockCrashReporter.getDataCallCount)
        XCTAssertEqual(0, mockCrashReporter.purgePendingCrashReportCallCount)
    }

    func testPendingCrashCausesAGetDataMethod() {
        mockCrashReporter.pendingCrashReport = true
        let _ = CrashModule(context: context, delegate: self, diskStorage: nil, crashReporter: mockCrashReporter)
        XCTAssertEqual(1, mockCrashReporter.getDataCallCount)
    }

    func testPendingCrashCausesAPurgePendingCrashes() {
        mockCrashReporter.pendingCrashReport = true
        let _ = CrashModule(context: context, delegate: self, diskStorage: nil, crashReporter: mockCrashReporter)
        XCTAssertEqual(1, mockCrashReporter.purgePendingCrashReportCallCount)
    }

    func testDataDoesntChangeAfterInitialGet() {
        mockCrashReporter.pendingCrashReport = true
        mockCrashReporter._data[TealiumDataKey.crashCount] = 1
        let crashModule = CrashModule(context: context, delegate: self, diskStorage: nil, crashReporter: mockCrashReporter)
        XCTAssertEqual(crashModule.data?[TealiumDataKey.crashCount] as? Int, 1)
        mockCrashReporter._data[TealiumDataKey.crashCount] = 2
        XCTAssertEqual(crashModule.data?[TealiumDataKey.crashCount] as? Int, 1)
    }

    func testCrashEventIsRequested() {
        let crasheEventTracked = expectation(description: "Crash event is tracked")
        onRequestTrack = { trackRequest in
            if trackRequest.event == TealiumKey.crashEvent {
                crasheEventTracked.fulfill()
            }
        }
        mockCrashReporter.pendingCrashReport = true
        context.config.sendCrashDataOnCrashDetected = true
        let _ = CrashModule(context: context, delegate: self, diskStorage: nil, crashReporter: mockCrashReporter)
        waitForExpectations(timeout: 1.0)
    }
}

extension CrashModuleTests: ModuleDelegate {
    func processRemoteCommandRequest(_ request: TealiumRequest) {

    }

    func requestTrack(_ track: TealiumTrackRequest) {
        onRequestTrack?(track)
    }

    func requestDequeue(reason: String) {

    }
}

class MockTealiumCrashReporter: CrashReporterProtocol {

    var pendingCrashReport = false
    var isEnabled = false
    var hasPendingCrashReportCalledCount = 0
    var enableCallCount = 0
    var loadPendingCrashReportDataCalledCount = 0
    var purgePendingCrashReportCallCount = 0
    var getDataCallCount = 0

    func hasPendingCrashReport() -> Bool {
        hasPendingCrashReportCalledCount += 1
        return pendingCrashReport
    }

    func enable() -> Bool {
        enableCallCount += 1
        return isEnabled
    }

    func loadPendingCrashReportData() -> Data! {
        loadPendingCrashReportDataCalledCount += 1
        return Data()
    }

    func purgePendingCrashReport() -> Bool {
        purgePendingCrashReportCallCount += 1
        pendingCrashReport = false
        return pendingCrashReport
    }

    func disable() {
        purgePendingCrashReportCallCount += 1
        pendingCrashReport = false
    }

    func purgePendingCrashReport() {
        purgePendingCrashReportCallCount += 1
        pendingCrashReport = false
    }
    var _data: [String: Any] = ["a": "1"]
    var data: [String: Any]? {
        getDataCallCount += 1
        return _data
    }
}

class MockDataLayer: DataLayerManagerProtocol {
    
    var all = [String : Any]()
    var allSessionData = [String : Any]()
    var sessionId: String?
    var sessionData = [String : Any]()
    
    func add(data: [String : Any], expiry: Expiry?) { }
    
    func add(key: String, value: Any, expiry: Expiry?) { }
    
    func joinTrace(id: String) { }
    
    func leaveTrace() { }
    
    func delete(for keys: [String]) { }
    
    func delete(for key: String) { }
    
    func deleteAll() { }
    
    func add(data: [String : Any], expiry: Expiry) {
    }
    
    func add(key: String, value: Any, expiry: Expiry) {
    }
}
