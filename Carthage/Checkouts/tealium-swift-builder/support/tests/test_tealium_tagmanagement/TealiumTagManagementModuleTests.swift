//
//  TealiumTagManagementModuleTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 12/16/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

@testable import TealiumCore
@testable import TealiumTagManagement
import XCTest

class TealiumTagManagementModuleTests: XCTestCase {

    var expect: XCTestExpectation!
    var module: TealiumTagManagementModule!
    var config: TealiumConfig!
    var mockTagmanagement: MockTagManagementWebView!

    override func setUp() {
        super.setUp()
        config = TealiumConfig(account: "testAccount", profile: "testProfile", environment: "testEnv")
    }

    func testDispatchTrackCreatesTrackRequest() {
        expect = expectation(description: "trackRequest")
        module = TealiumTagManagementModule(config: config, delegate: self, completion: { _ in })
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        module?.dispatchTrack(track, completion: { result in
            switch result.0 {
            case .failure(let error):
                XCTFail("Unexpected error: \(error.localizedDescription)")
            case .success(let success):
                XCTAssertTrue(success)
                self.expect.fulfill()
            }
        })
        wait(for: [expect], timeout: 2.0)
    }

    func testDispatchTrackCreatesBatchTrackRequest() {
        expect = expectation(description: "batchTrackRequest")
        module = TealiumTagManagementModule(config: config, delegate: self, completion: { _ in })
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        let batchTrack = TealiumBatchTrackRequest(trackRequests: [track, track, track], completion: nil)
        module?.dispatchTrack(batchTrack, completion: { result in
            switch result.0 {
            case .failure(let error):
                XCTFail("Unexpected error: \(error.localizedDescription)")
            case .success(let success):
                XCTAssertTrue(success)
                self.expect.fulfill()
            }
        })
        wait(for: [expect], timeout: 2.0)
    }

    func testDynamicTrackWithErrorReloadsAndSucceeds() {
        expect = expectation(description: "dynamicTrackWithErrorReloadsAndSucceeds")
        mockTagmanagement = MockTagManagementWebView(success: true)
        module = TealiumTagManagementModule(config: config, delegate: self, tagManagement: mockTagmanagement)
        module?.errorState = AtomicInteger(value: 1)
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        module?.dynamicTrack(track, completion: nil)
        XCTAssertEqual(mockTagmanagement.reloadCallCount, 1)
        XCTAssertEqual(module.errorState.value, 0)
        expect.fulfill()
        wait(for: [expect], timeout: 2.0)
    }

    func testDynamicTrackWithErrorReloadsAndFails() {
        expect = expectation(description: "dynamicTrackWithErrorReloadsAndFails")
        mockTagmanagement = MockTagManagementWebView(success: false)
        module = TealiumTagManagementModule(config: config, delegate: self, tagManagement: mockTagmanagement)
        module?.errorState = AtomicInteger(value: 1)
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        module?.dynamicTrack(track, completion: nil)
        XCTAssertEqual(mockTagmanagement.reloadCallCount, 1)
        XCTAssertEqual(module.errorState.value, 2)
        expect.fulfill()
        wait(for: [expect], timeout: 2.0)
    }

    func testEnableNotificationsTriggersEvaluateJavascriptMethod() {
        expect = expectation(description: "dynamicTrackWithErrorReloadsAndFails")
        mockTagmanagement = MockTagManagementWebView(success: true)
        module = TealiumTagManagementModule(config: config, delegate: self, tagManagement: mockTagmanagement)
        module.enableNotifications()
        let notificationName = Notification.Name(rawValue: TealiumKey.jsNotificationName)
        let jsString = "try { utag.mobile.remote_api.response['test']['test']('test','test')} catch(err) {console.error(err)}"
        let notification = Notification(name: notificationName,
                                        object: self,
                                        userInfo: ["js": jsString])
        NotificationCenter.default.post(notification)
        XCTAssertEqual(mockTagmanagement.evaluateJavascriptCallCount, 2)
        expect.fulfill()
        wait(for: [expect], timeout: 2.0)
    }

    func testEnqueueWhenRequestIsAcceptable() {
        expect = expectation(description: "testEnqueueWhenRequestIsAcceptable")
        module = TealiumTagManagementModule(config: config, delegate: self, completion: nil)
        let track = TealiumTrackRequest(data: ["test": "track"])
        let batch = TealiumBatchTrackRequest(trackRequests: [track, track, track], completion: nil)
        let remote = TealiumRemoteAPIRequest(trackRequest: track)

        module.enqueue(track, completion: nil)
        XCTAssertEqual(module.pendingTrackRequests.count, 1)
        if let request = module.pendingTrackRequests[0].0 as? TealiumTrackRequest {
            XCTAssertEqual(request.trackDictionary["test"] as! String, "track")
        }

        module = TealiumTagManagementModule(config: config, delegate: self, completion: nil)

        module.enqueue(batch, completion: nil)
        XCTAssertEqual(module.pendingTrackRequests.count, 1)
        if let request = module.pendingTrackRequests[0].0 as? TealiumTrackRequest {
            XCTAssertEqual(request.trackDictionary["test"] as! String, "track")
        }

        module = TealiumTagManagementModule(config: config, delegate: self, completion: nil)

        module.enqueue(remote, completion: nil)
        XCTAssertEqual(module.pendingTrackRequests.count, 1)
        if let request = module.pendingTrackRequests[0].0 as? TealiumTrackRequest {
            XCTAssertEqual(request.trackDictionary["test"] as! String, "track")
        }
        expect.fulfill()
        wait(for: [expect], timeout: 2.0)
    }

    func testEnqueueWhenRequestIsNotAcceptable() {
        expect = expectation(description: "testEnqueueWhenRequestIsNotAcceptable")
        module = TealiumTagManagementModule(config: config, delegate: self, completion: nil)
        let req = TealiumEnqueueRequest(data: TealiumTrackRequest(data: ["test": "track"]), completion: nil)

        module.enqueue(req, completion: nil)
        XCTAssertEqual(module.pendingTrackRequests.count, 0)

        expect.fulfill()
        wait(for: [expect], timeout: 2.0)
    }

    func testflushQueueSuccess() {
        expect = expectation(description: "testflushQueueSuccess")
        mockTagmanagement = MockTagManagementWebView(success: true)
        module = TealiumTagManagementModule(config: config, delegate: self, tagManagement: mockTagmanagement)
        let track = TealiumTrackRequest(data: ["test": "track"])
        module.pendingTrackRequests.append((track, nil))
        module.webViewState = Atomic(value: .loadSuccess)
        module.flushQueue()

        XCTAssertEqual(module.pendingTrackRequests.count, 0)

        expect.fulfill()
        wait(for: [expect], timeout: 2.0)
    }

    func testflushQueueFail() {
        expect = expectation(description: "testflushQueueFail")
        mockTagmanagement = MockTagManagementWebView(success: false)
        module = TealiumTagManagementModule(config: config, delegate: self, tagManagement: mockTagmanagement)
        let track = TealiumTrackRequest(data: ["test": "track"])
        module.pendingTrackRequests.append((track, nil))
        module.webViewState = Atomic(value: .loadSuccess)
        module.flushQueue()

        XCTAssertEqual(module.pendingTrackRequests.count, 1)

        expect.fulfill()
        wait(for: [expect], timeout: 2.0)
    }

    func testPrepareforDispatchAddsModuleName() {
        let incomingTrack = TealiumTrackRequest(data: ["incoming": "track"])
        module = TealiumTagManagementModule(config: config, delegate: self, completion: nil)
        let result = module.prepareForDispatch(incomingTrack).trackDictionary
        XCTAssertEqual(result[TealiumKey.dispatchService] as! String, TealiumTagManagementKey.moduleName)
    }

}

extension TealiumTagManagementModuleTests: TealiumModuleDelegate {
    func requestReleaseQueue(reason: String) {

    }

    func requestTrack(_ track: TealiumTrackRequest) {
    }
}
