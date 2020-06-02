//
//  TealiumCollectModuleTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 11/1/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

@testable import TealiumCollect
@testable import TealiumCore
import XCTest

class TealiumCollectModuleTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBatchTrack() {
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = TealiumCollectPostDispatcher(dispatchURL: "https://collect.tealiumiq.com", urlSession: MockURLSession(), completion: nil)
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        let batchTrack = TealiumBatchTrackRequest(trackRequests: [track, track, track], completion: nil)
        collectModule.batchTrack(batchTrack) { result in
            switch result.0 {
            case .failure(let error):
                XCTFail("Unexpected failure: \(error.localizedDescription)")
            case .success(let success):
                XCTAssertTrue(success)
            }
        }
    }

    func testBatchTrackInvalidRequest() {
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = TealiumCollectPostDispatcher(dispatchURL: "https://collect.tealiumiq.com", urlSession: MockURLSession(), completion: nil)
        //        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        let batchTrack = TealiumBatchTrackRequest(trackRequests: [], completion: nil)
        collectModule.batchTrack(batchTrack) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.invalidBatchRequest)
            case .success:
                XCTFail("Unexpected success")
            }
        }
    }

    func testBatchTrackCollectNotInitialized() {
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = nil
        //        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        let batchTrack = TealiumBatchTrackRequest(trackRequests: [], completion: nil)
        collectModule.batchTrack(batchTrack) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.collectNotInitialized)
            case .success(let success):
                XCTFail("Unexpected success")
            }
        }
    }

    func testTrack() {
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = TealiumCollectPostDispatcher(dispatchURL: "https://collect.tealiumiq.com", urlSession: MockURLSession(), completion: nil)
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        collectModule.track(track) { result in
            switch result.0 {
            case .failure(let error):
                XCTFail("Unexpected failure: \(error.localizedDescription)")
            case .success(let success):
                XCTAssertTrue(success)
            }
        }
    }

    func testTrackCollectNotInitialized() {
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = nil
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        collectModule.track(track) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.collectNotInitialized)
            case .success(let success):
                XCTFail("Unexpected success")
            }
        }
    }

    func testCollectNil() {
        let expectation = self.expectation(description: "dynamic track")
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = nil
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        collectModule.dynamicTrack(track) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.collectNotInitialized)
                expectation.fulfill()
            case .success:
                XCTFail("Unexpected success")
            }
        }
        wait(for: [expectation], timeout: 4.0)
    }

    func testPrepareForDispatch() {
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        //            collectModule.enable(TealiumEnableRequest(config: config, enableCompletion: nil))
        let track = TealiumTrackRequest(data: [String: Any](), completion: nil)
        let newTrack = collectModule.prepareForDispatch(track).trackDictionary
        XCTAssertNotNil(newTrack[TealiumKey.account])
        XCTAssertNotNil(newTrack[TealiumKey.profile])
    }

    func testDynamicDispatchSingleTrack() {
        let expectation = self.expectation(description: "dynamic track")
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = TealiumCollectPostDispatcher(dispatchURL: "https://collect.tealiumiq.com", urlSession: MockURLSession(), completion: nil)
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        collectModule.dynamicTrack(track) { result in
            switch result.0 {
            case .failure(let error):
                return
            case .success(let success):
                XCTAssertTrue(success)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 4.0)
    }

    func testDynamicDispatchSingleTrackConsentCookie() {
        let expectation = self.expectation(description: "dynamic track")
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = TealiumCollectPostDispatcher(dispatchURL: "https://collect.tealiumiq.com", urlSession: MockURLSession(), completion: nil)
        let track = TealiumTrackRequest(data: [TealiumKey.event: "update_consent_cookie"], completion: nil)
        collectModule.dynamicTrack(track) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.trackNotApplicableForCollectModule)
                expectation.fulfill()
            case .success:
                XCTFail("Unexpected success")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 4.0)
    }

    func testDynamicDispatchBatchTrack() {
        let expectation = self.expectation(description: "dynamic track")
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = TealiumCollectPostDispatcher(dispatchURL: "https://collect.tealiumiq.com", urlSession: MockURLSession(), completion: nil)
        let track = TealiumTrackRequest(data: ["test_track": true], completion: nil)
        let batchRequest = TealiumBatchTrackRequest(trackRequests: [track], completion: nil)
        collectModule.dynamicTrack(batchRequest) { result in
            switch result.0 {
            case .failure(let error):
                XCTFail("Unexpected error: \(error.localizedDescription)")
            case .success(let success):
                XCTAssertTrue(success)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 4.0)
    }

    func testDynamicDispatchBatchTrackConsentCookie() {
        let expectation = self.expectation(description: "dynamic track")
        let collectModule = TealiumCollectModule(config: testTealiumConfig, delegate: self, completion: nil)
        collectModule.collect = TealiumCollectPostDispatcher(dispatchURL: "https://collect.tealiumiq.com", urlSession: MockURLSession(), completion: nil)
        let track = TealiumTrackRequest(data: [TealiumKey.event: "update_consent_cookie"], completion: nil)
        let batchRequest = TealiumBatchTrackRequest(trackRequests: [track], completion: nil)
        collectModule.dynamicTrack(batchRequest) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.trackNotApplicableForCollectModule)
                expectation.fulfill()
            case .success:
                XCTFail("Unexpected success")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 4.0)
    }

    func testUpdateCollectDispatcher() {
        let config = TealiumConfig(account: "dummy", profile: "dummy", environment: "dummy")
        let collectModule = TealiumCollectModule(config: config, delegate: self, completion: nil)
        collectModule.updateCollectDispatcher(config: config) { result in
            switch result.0 {
            case .failure:
                XCTFail("Unexpected error")
            case .success(let success):
                XCTAssertTrue(success)
            }
        }
    }

    func testUpdateCollectDispatcherInvalidURL() {
        let config = testTealiumConfig.copy
        let collectModule = TealiumCollectModule(config: config, delegate: self, completion: nil)
        config.collectOverrideURL = "tealium"
        collectModule.updateCollectDispatcher(config: config) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.invalidDispatchURL)
            case .success:
                XCTFail("Unexpected success")
            }
        }
    }

    func testOverrideCollectURL() {
        let config = testTealiumConfig.copy
        config.collectOverrideURL = "https://collect.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile&tealium_profile=someprofile"
        XCTAssertTrue(config.optionalData[TealiumCollectKey.overrideCollectUrl] as! String == "https://collect.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile&tealium_profile=someprofile&")
    }

    func testOverrideCollectProfile() {
        let config = testTealiumConfig.copy
        config.collectOverrideProfile = "hello"
        XCTAssertTrue(config.optionalData[TealiumCollectKey.overrideCollectProfile] as! String == "hello")
    }

}

extension TealiumCollectModuleTests: TealiumModuleDelegate {
    func requestTrack(_ track: TealiumTrackRequest) {

    }

    func requestReleaseQueue(reason: String) {

    }

}
