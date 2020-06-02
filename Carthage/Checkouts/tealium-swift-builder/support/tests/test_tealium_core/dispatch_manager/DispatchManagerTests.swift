//
//  DispatchQueueModuleTests.swift
//  tealium-swift
//
//  Created by Craig Rouse on 01/05/18.
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

import Foundation
@testable import TealiumCore
import XCTest

class TealiumDispatchQueueModuleTests: XCTestCase {

    static var releaseExpectation: XCTestExpectation?
    static var remoteAPIExpectation: XCTestExpectation?
    static var expiredDispatchesExpectation: XCTestExpectation?
    static var connectivity: TealiumConnectivity {
        let connectivity = TealiumConnectivity(config: testTealiumConfig, delegate: nil, diskStorage: nil) { result in }
        connectivity.forceConnectionOverride = true
        return connectivity
    }
    var dispatchManager: DispatchManager!
    var diskStorage = DispatchQueueMockDiskStorage()
    
    var persistentQueue: TealiumPersistentDispatchQueue!
    var delegate: TealiumModuleDelegate?
    override func setUp() {
        super.setUp()
        self.persistentQueue = TealiumPersistentDispatchQueue(diskStorage: diskStorage)
        // Put setup code here. This method is called before the invocation of each test method in the class.
     
    }

    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNegativeDispatchLimit() {
        dispatchManager = DispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: TealiumDispatchQueueModuleTests.connectivity, config: testTealiumConfig.copy, diskStorage: DispatchQueueMockDiskStorage())
        dispatchManager.config.dispatchQueueLimit = -1
        XCTAssertEqual(dispatchManager.maxQueueSize, TealiumValue.defaultMaxQueueSize)
        dispatchManager.config.dispatchQueueLimit = -100
        XCTAssertEqual(dispatchManager.maxQueueSize, TealiumValue.defaultMaxQueueSize)
        dispatchManager.config.dispatchQueueLimit = -5
        XCTAssertEqual(dispatchManager.maxQueueSize, TealiumValue.defaultMaxQueueSize)
    }
    
    func testTrack() {
        
        let config = TestTealiumHelper().getConfig()
        config.batchingEnabled = true
        dispatchManager = DispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: TealiumDispatchQueueModuleTests.connectivity, config: config, diskStorage: DispatchQueueMockDiskStorage())
        dispatchManager.clearQueue()
        let trackRequest = TealiumTrackRequest(data: ["tealium_event": "hello"], completion: nil)
        dispatchManager.processTrack(trackRequest)
        XCTAssertEqual(dispatchManager.persistentQueue.currentEvents, 1)
        dispatchManager.processTrack(trackRequest)
        XCTAssertEqual(dispatchManager.persistentQueue.currentEvents, 2)
        // wake event should not be queued
        let wakeRequest = TealiumTrackRequest(data: ["tealium_event": "wake"], completion: nil)
        dispatchManager.processTrack(wakeRequest)
        XCTAssertEqual(dispatchManager.persistentQueue.currentEvents, 3)
    }
    
    func testQueue() {
        let config = TestTealiumHelper().getConfig()
        config.batchingEnabled = true
        dispatchManager = DispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: TealiumDispatchQueueModuleTests.connectivity, config: config, diskStorage: DispatchQueueMockDiskStorage())
        dispatchManager.clearQueue()
        let trackRequest = TealiumTrackRequest(data: ["tealium_event": "wake"], completion: nil)
        let batchTrack = TealiumBatchTrackRequest(trackRequests: [trackRequest, trackRequest], completion: nil)
        dispatchManager.queue(TealiumEnqueueRequest(data: batchTrack, completion: nil))
        XCTAssertEqual(dispatchManager.persistentQueue.currentEvents, 2)
    }
    
    func testRemoveOldDispatches() {
        TealiumDispatchQueueModuleTests.expiredDispatchesExpectation = self.expectation(description: "remove old dispatches")
        let config = testTealiumConfig
        config.dispatchExpiration = 1
        dispatchManager = DispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: TealiumDispatchQueueModuleTests.connectivity, config: testTealiumConfig.copy, diskStorage: DispatchQueueMockDiskStorage())
        dispatchManager.persistentQueue = MockPersistentQueue(diskStorage: diskStorage)
        dispatchManager.config = config
        dispatchManager.removeOldDispatches()
        wait(for: [TealiumDispatchQueueModuleTests.expiredDispatchesExpectation!], timeout: 5.0)
    }
    
    #if os(iOS)
    func testRemoteAPIEnabled() {
        let config = TestTealiumHelper().getConfig()
        config.remoteAPIEnabled = true
        dispatchManager = DispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: TealiumDispatchQueueModuleTests.connectivity, config: config, diskStorage: DispatchQueueMockDiskStorage())
        TealiumDispatchQueueModuleTests.remoteAPIExpectation = self.expectation(description: "remote api")

        let dispatcher = DummyDispatcher(config: config, delegate: self, completion: nil)
        dispatchManager.dispatchers = [dispatcher]
        
        let trackRequest = TealiumTrackRequest(data: ["tealium_event": "myevent"], completion: nil)
        dispatchManager.processTrack(trackRequest)
        wait(for: [TealiumDispatchQueueModuleTests.remoteAPIExpectation!], timeout: 5.0)
    }
    #endif
    
    func testReleaseQueue() {
        let config = TestTealiumHelper().getConfig()
        #if os(iOS)
        config.remoteAPIEnabled = true
        #endif
        config.logLevel = .silent
        dispatchManager = DispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: TealiumDispatchQueueModuleTests.connectivity, config: config, diskStorage: DispatchQueueMockDiskStorage())
        dispatchManager.clearQueue()
        let trackRequest = TealiumTrackRequest(data: ["tealium_event": "wake"], completion: nil)
        let batchTrack = TealiumBatchTrackRequest(trackRequests: [trackRequest, trackRequest], completion: nil)
        dispatchManager.queue(TealiumEnqueueRequest(data: batchTrack, completion: nil))
        XCTAssertEqual(dispatchManager.persistentQueue.currentEvents, 2)
        dispatchManager.releaseQueue()
        XCTAssertEqual(dispatchManager.persistentQueue.currentEvents, 0)
    }
    
    func testClearQueue() {
        let config = TestTealiumHelper().getConfig()
        #if os(iOS)
        config.remoteAPIEnabled = true
        #endif
        config.logLevel = .silent
        dispatchManager = DispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: TealiumDispatchQueueModuleTests.connectivity, config: config, diskStorage: DispatchQueueMockDiskStorage())
        dispatchManager.clearQueue()
        let trackRequest = TealiumTrackRequest(data: ["tealium_event": "wake"], completion: nil)
        let batchTrack = TealiumBatchTrackRequest(trackRequests: [trackRequest, trackRequest], completion: nil)
        dispatchManager.queue(TealiumEnqueueRequest(data: batchTrack, completion: nil))
        XCTAssertEqual(dispatchManager.persistentQueue.currentEvents, 2)
        dispatchManager.clearQueue()
        XCTAssertEqual(dispatchManager.persistentQueue.currentEvents, 0)
    }


    func testCanQueueRequest() {
        let config = TestTealiumHelper().getConfig()
        #if os(iOS)
        config.remoteAPIEnabled = true
        #endif
        config.logLevel = .silent
        dispatchManager = DispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: TealiumDispatchQueueModuleTests.connectivity, config: config, diskStorage: DispatchQueueMockDiskStorage())
        XCTAssertFalse(dispatchManager.canQueueRequest(TealiumTrackRequest(data: ["tealium_event": "grant_full_consent"], completion: nil)))
        XCTAssertTrue(dispatchManager.canQueueRequest(TealiumTrackRequest(data: ["tealium_event": "view"], completion: nil)))
        config.batchingBypassKeys = ["view"]
        dispatchManager.config = config
        XCTAssertFalse(dispatchManager.canQueueRequest(TealiumTrackRequest(data: ["tealium_event": "view"], completion: nil)))
    }

}

class MockPersistentQueue: TealiumPersistentDispatchQueue {
    override func removeOldDispatches(_ maxQueueSize: Int, since: Date? = nil) {
        XCTAssertNotNil(since)
        TealiumDispatchQueueModuleTests.expiredDispatchesExpectation!.fulfill()
    }
}

extension TealiumDispatchQueueModuleTests: TealiumModuleDelegate {
    func requestTrack(_ track: TealiumTrackRequest) {
        
    }
    
    func requestReleaseQueue(reason: String) {
        
    }
    
    
}

class DummyDispatcher: Dispatcher {
    var isReady: Bool = true
    
    required init(config: TealiumConfig, delegate: TealiumModuleDelegate, completion: ModuleCompletion?) {
        self.config = config
    }
    
    func dynamicTrack(_ request: TealiumRequest, completion: ModuleCompletion?) {
        guard request is TealiumRemoteAPIRequest else {
            return
        }
        TealiumDispatchQueueModuleTests.remoteAPIExpectation!.fulfill()
    }
    
    var moduleId: String = "DummyDispatcher"
    
    var config: TealiumConfig
    
    
}
