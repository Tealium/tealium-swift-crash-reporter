//
//  TealiumModulesManagerTests.swift
//  tealium-swift
//
//  Created by Craig Rouse on 04/30/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

//@testable import TealiumAppData
//@testable import TealiumCollect
//@testable import TealiumConsentManager
@testable import TealiumCore
//@testable import TealiumDelegate
//@testable import TealiumDeviceData
//@testable import TealiumAttribution
//@testable import TealiumVisitorService
import XCTest

var defaultTealiumConfig: TealiumConfig { TealiumConfig(account: "tealiummobile",
                                                        profile: "demo",
                                                        environment: "dev",
                                                        optionalData: nil)
}

class TealiumModulesManagerTests: XCTestCase {

    static var expectatations = [String: XCTestExpectation]()

    var modulesManager: ModulesManager {
        let config = testTealiumConfig
        config.logLevel = TealiumLogLevel.error
        config.loggerType = .print
        return ModulesManager(config, eventDataManager: nil)
    }

    func modulesManagerForConfig(config: TealiumConfig) -> ModulesManager {
        return ModulesManager(config, eventDataManager: nil)
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        TealiumModulesManagerTests.expectatations = [:]
    }

    func testUpdateConfig() {
        let modulesManager = self.modulesManager

        XCTAssertTrue(testTealiumConfig.isCollectEnabled)
        XCTAssertTrue(testTealiumConfig.isTagManagementEnabled)

        XCTAssertTrue(modulesManager.dispatchers.contains(where: { $0.moduleId == "Tag Management" }))
        XCTAssertTrue(modulesManager.dispatchers.contains(where: { $0.moduleId == "Collect" }))

        let config = testTealiumConfig
        config.shouldUseRemotePublishSettings = false
        config.isCollectEnabled = false
        config.isTagManagementEnabled = true
        modulesManager.updateConfig(config: config)
        XCTAssertFalse(modulesManager.dispatchers.contains(where: { $0.moduleId == "Collect" }))
        XCTAssertTrue(modulesManager.dispatchers.contains(where: { $0.moduleId == "Tag Management" }))
        config.isTagManagementEnabled = false
        modulesManager.updateConfig(config: config)
        XCTAssertFalse(modulesManager.dispatchers.contains(where: { $0.moduleId == "Tag Management" }))
        config.isTagManagementEnabled = true
        config.isCollectEnabled = true
        modulesManager.updateConfig(config: config)
        XCTAssertTrue(modulesManager.dispatchers.contains(where: { $0.moduleId == "Tag Management" }))
        XCTAssertTrue(modulesManager.dispatchers.contains(where: { $0.moduleId == "Collect" }))
    }

    func testAddCollector() {
        let collector = DummyCollector(config: testTealiumConfig, delegate: self, diskStorage: nil) { _ in

        }
        let modulesManager = self.modulesManager

        modulesManager.collectors = []
        modulesManager.dispatchListeners = []
        modulesManager.dispatchValidators = []

        modulesManager.addCollector(collector)
        XCTAssertTrue(modulesManager.collectors.contains(where: { $0.moduleId == "Dummy" }))

        XCTAssertTrue(modulesManager.dispatchListeners.contains(where: { ($0 as! Collector).moduleId == "Dummy" }))
        XCTAssertTrue(modulesManager.dispatchValidators.contains(where: { ($0 as! Collector).moduleId == "Dummy" }))

        XCTAssertEqual(modulesManager.collectors.count, 1)
        XCTAssertEqual(modulesManager.dispatchListeners.count, 1)

        modulesManager.addCollector(collector)
        modulesManager.addCollector(collector)

        XCTAssertEqual(modulesManager.collectors.count, 1)
        XCTAssertEqual(modulesManager.dispatchListeners.count, 1)
        XCTAssertEqual(modulesManager.dispatchValidators.count, 1)
    }

    func testDisableModule() {
        let modulesManager = self.modulesManager

        modulesManager.eventDataManager = DummyDataManagerNoData()
        let collector = DummyCollector(config: testTealiumConfig, delegate: self, diskStorage: nil) { _ in

        }
        modulesManager.collectors = [collector]
        XCTAssertEqual(modulesManager.collectors.count, 1)
        modulesManager.disableModule(id: "Dummy")
        XCTAssertEqual(modulesManager.collectors.count, 0)
        modulesManager.disableModule(id: "Tag Management")
        XCTAssertEqual(modulesManager.dispatchers.count, 1)

    }

    func testGatherTrackData() {
        let modulesManager = self.modulesManager
        modulesManager.collectors = []
        modulesManager.eventDataManager = DummyDataManagerNoData()
        let collector = DummyCollector(config: testTealiumConfig, delegate: self, diskStorage: nil) { _ in

        }
        modulesManager.addCollector(collector)
        let data = modulesManager.gatherTrackData(for: ["testGatherTrackData": true]) as! [String: Bool]

        XCTAssertEqual(["testGatherTrackData": true, "dummy": true], data)
        modulesManager.eventDataManager = DummyDataManager()
        let dataWithEventData = modulesManager.gatherTrackData(for: ["testGatherTrackData": true]) as! [String: Bool]
        XCTAssertEqual(["testGatherTrackData": true, "dummy": true, "eventData": true, "sessionData": true], dataWithEventData)
    }

    func testConnectionRestored() {
        let modulesManager = self.modulesManager
        modulesManager.collectors = []
        modulesManager.dispatchers = []
        modulesManager.eventDataManager = DummyDataManagerNoData()

        XCTAssertEqual(modulesManager.dispatchers.count, 0)

        modulesManager.connectionRestored()

        XCTAssertEqual(modulesManager.dispatchers.count, 2)
    }

    func testSendTrack() {
        TealiumModulesManagerTests.expectatations["sendTrack"] = expectation(description: "sendTrack")
        let modulesManager = self.modulesManager
        modulesManager.collectors = []
        modulesManager.dispatchers = []
        modulesManager.eventDataManager = DummyDataManagerNoData()
        let connectivity = TealiumConnectivity(config: testTealiumConfig, delegate: nil, diskStorage: nil) { _ in }
        modulesManager.dispatchManager = DummyDispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: connectivity, config: testTealiumConfig)

        let track = TealiumTrackRequest(data: [:])
        modulesManager.sendTrack(track)
        wait(for: [TealiumModulesManagerTests.expectatations["sendTrack"]!], timeout: 1.0)
    }

    func testRequestTrack() {
        TealiumModulesManagerTests.expectatations["requestTrack"] = expectation(description: "requestTrack")
        let modulesManager = self.modulesManager
        modulesManager.collectors = []
        modulesManager.dispatchers = []
        modulesManager.eventDataManager = DummyDataManagerNoData()
        let connectivity = TealiumConnectivity(config: testTealiumConfig, delegate: nil, diskStorage: nil) { _ in }
        modulesManager.dispatchManager = DummyDispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: connectivity, config: testTealiumConfig)

        let track = TealiumTrackRequest(data: [:])
        modulesManager.sendTrack(track)
        wait(for: [TealiumModulesManagerTests.expectatations["requestTrack"]!], timeout: 1.0)
    }

    func testReleaseQueue() {
        TealiumModulesManagerTests.expectatations["releaseQueue"] = expectation(description: "releaseQueue")
        let modulesManager = self.modulesManager
        modulesManager.collectors = []
        modulesManager.dispatchers = []
        modulesManager.eventDataManager = DummyDataManagerNoData()
        let connectivity = TealiumConnectivity(config: testTealiumConfig, delegate: nil, diskStorage: nil) { _ in }
        modulesManager.dispatchManager = DummyDispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: connectivity, config: testTealiumConfig)

        modulesManager.requestReleaseQueue(reason: "test")
        wait(for: [TealiumModulesManagerTests.expectatations["releaseQueue"]!], timeout: 1.0)
    }

    func testSetupDispatchListeners() {
        let collector = DummyCollector(config: testTealiumConfig, delegate: self, diskStorage: nil) { _ in

        }
        let modulesManager = self.modulesManager

        modulesManager.collectors = []
        modulesManager.dispatchListeners = []
        modulesManager.dispatchValidators = []
        let config = testTealiumConfig
        config.dispatchListeners = [collector]
        modulesManager.setupDispatchListeners(config: config)
        XCTAssertEqual(modulesManager.dispatchListeners.count, 1)
        XCTAssertTrue(modulesManager.dispatchListeners.contains(where: { ($0 as! Collector).moduleId == "Dummy" }))
    }

    func testSetupDispatchValidators() {
        let collector = DummyCollector(config: testTealiumConfig, delegate: self, diskStorage: nil) { _ in

        }
        let modulesManager = self.modulesManager

        modulesManager.collectors = []
        modulesManager.dispatchListeners = []
        modulesManager.dispatchValidators = []
        let config = testTealiumConfig
        config.dispatchValidators = [collector]
        modulesManager.setupDispatchValidators(config: config)
        XCTAssertEqual(modulesManager.dispatchValidators.count, 1)
        XCTAssertTrue(modulesManager.dispatchValidators.contains(where: { ($0 as! Collector).moduleId == "Dummy" }))
    }

    func testConfigPropertyUpdate() {
        let collector = DummyCollector(config: testTealiumConfig, delegate: self, diskStorage: nil) { _ in

        }
        TealiumModulesManagerTests.expectatations["configPropertyUpdate"] = expectation(description: "configPropertyUpdate")
        TealiumModulesManagerTests.expectatations["configPropertyUpdateModule"] = expectation(description: "configPropertyUpdateModule")
        let modulesManager = self.modulesManager

        modulesManager.collectors = [collector]
        modulesManager.dispatchListeners = []
        modulesManager.dispatchValidators = []
        let connectivity = TealiumConnectivity(config: testTealiumConfig, delegate: nil, diskStorage: nil) { _ in }
        modulesManager.dispatchManager = DummyDispatchManager(dispatchers: nil, dispatchValidators: nil, dispatchListeners: nil, connectivityManager: connectivity, config: testTealiumConfig)
        let config = testTealiumConfig
        config.logLevel = .info
        modulesManager.config = config
        XCTAssertEqual(modulesManager.config, modulesManager.dispatchManager!.config)
        wait(for: [TealiumModulesManagerTests.expectatations["configPropertyUpdate"]!, TealiumModulesManagerTests.expectatations["configPropertyUpdateModule"]!], timeout: 1.0)
    }

    func testSetModules() {
        let collector = DummyCollector(config: testTealiumConfig, delegate: self, diskStorage: nil) { _ in

        }
        let modulesManager = self.modulesManager
        modulesManager.dispatchListeners = []
        modulesManager.dispatchValidators = []
        modulesManager.dispatchers = []
        modulesManager.collectors = [collector]
        XCTAssertEqual(modulesManager.modules.count, modulesManager.collectors.count)
        modulesManager.modules = [collector, collector]
        XCTAssertEqual(modulesManager.modules.count, modulesManager.collectors.count)
        modulesManager.modules = []
        XCTAssertEqual(modulesManager.modules.count, modulesManager.collectors.count)
        XCTAssertEqual(modulesManager.modules.count, 0)
    }

    func testDispatchValidatorAddedFromConfig() {
        let validator = DummyCollector(config: testTealiumConfig, delegate: self, diskStorage: nil) { _ in

        }
        let config = testTealiumConfig
        config.dispatchValidators = [validator]
        let modulesManager = self.modulesManagerForConfig(config: config)
        XCTAssertTrue(modulesManager.dispatchValidators.contains(where: { $0.id == "Dummy" }))
    }

    func testDispatchListenerAddedFromConfig() {
        let listener = DummyCollector(config: testTealiumConfig, delegate: self, diskStorage: nil) { _ in

        }
        let config = testTealiumConfig
        config.dispatchListeners = [listener]
        let modulesManager = self.modulesManagerForConfig(config: config)
        XCTAssertTrue(modulesManager.dispatchListeners.contains(where: { ($0 as! DispatchValidator).id == "Dummy" }))
    }

}

extension TealiumModulesManagerTests: TealiumModuleDelegate {
    func requestTrack(_ track: TealiumTrackRequest) {

    }

    func requestReleaseQueue(reason: String) {

    }

}

class DummyCollector: Collector, DispatchListener, DispatchValidator {
    var id: String

    func shouldQueue(request: TealiumRequest) -> (Bool, [String: Any]?) {
        return (false, nil)
    }

    func shouldDrop(request: TealiumRequest) -> Bool {
        return false
    }

    func shouldPurge(request: TealiumRequest) -> Bool {
        return false
    }

    func willTrack(request: TealiumRequest) {

    }

    var data: [String: Any]? {
        ["dummy": true]
    }

    required init(config: TealiumConfig, delegate: TealiumModuleDelegate?, diskStorage: TealiumDiskStorageProtocol?, completion: (ModuleResult) -> Void) {
        self.config = config
        self.id = "Dummy"
    }

    var moduleId: String = "Dummy"

    var config: TealiumConfig {
        willSet {
            TealiumModulesManagerTests.expectatations["configPropertyUpdateModule"]?.fulfill()
        }
    }

}

class DummyDataManager: EventDataManagerProtocol {
    var allEventData: [String: Any] = ["eventData": true, "sessionData": true]

    var allSessionData: [String: Any] = ["sessionData": true]

    var minutesBetweenSessionIdentifier: TimeInterval = TimeInterval(floatLiteral: 0.0)

    var secondsBetweenTrackEvents: TimeInterval = TimeInterval(floatLiteral: 0.0)

    var sessionId: String?

    var sessionData: [String: Any] = ["sessionData": true]

    var sessionStarter: SessionStarterProtocol = SessionStarter(config: testTealiumConfig)

    var tagManagementIsEnabled: Bool = true

    func add(data: [String: Any], expiration: Expiration) {

    }

    func add(key: String, value: Any, expiration: Expiration) {

    }

    func addTrace(id: String) {

    }

    func delete(forKeys: [String]) {

    }

    func delete(forKey key: String) {

    }

    func deleteAll() {

    }

    func leaveTrace() {

    }

    func refreshSessionData() {

    }

    func sessionRefresh() {

    }

    func startNewSession(with sessionStarter: SessionStarterProtocol) {

    }

}

class DummyDispatchManager: DispatchManagerProtocol {
    var dispatchers: [Dispatcher]?

    var dispatchListeners: [DispatchListener]?

    var dispatchValidators: [DispatchValidator]?

    var config: TealiumConfig {
        willSet {
            TealiumModulesManagerTests.expectatations["configPropertyUpdate"]?.fulfill()
        }
    }

    required init(dispatchers: [Dispatcher]?, dispatchValidators: [DispatchValidator]?, dispatchListeners: [DispatchListener]?, connectivityManager: TealiumConnectivity, config: TealiumConfig) {
        self.dispatchers = dispatchers
        self.dispatchValidators = dispatchValidators
        self.dispatchListeners = dispatchListeners
        self.config = config
    }

    func processTrack(_ request: TealiumTrackRequest) {
        XCTAssertEqual(request.trackDictionary.count, 1)
        XCTAssertNotNil(request.trackDictionary["request_uuid"])
        TealiumModulesManagerTests.expectatations["sendTrack"]?.fulfill()
        TealiumModulesManagerTests.expectatations["requestTrack"]?.fulfill()
    }

    func handleReleaseRequest(reason: String) {
        TealiumModulesManagerTests.expectatations["releaseQueue"]?.fulfill()
    }

}

class DummyDataManagerNoData: EventDataManagerProtocol {
    var allEventData: [String: Any] = [:]

    var allSessionData: [String: Any] = [:]

    var minutesBetweenSessionIdentifier: TimeInterval = TimeInterval(floatLiteral: 0.0)

    var secondsBetweenTrackEvents: TimeInterval = TimeInterval(floatLiteral: 0.0)

    var sessionId: String?

    var sessionData: [String: Any] = [:]

    var sessionStarter: SessionStarterProtocol = SessionStarter(config: testTealiumConfig)

    var tagManagementIsEnabled: Bool = true

    func add(data: [String: Any], expiration: Expiration) {

    }

    func add(key: String, value: Any, expiration: Expiration) {

    }

    func addTrace(id: String) {

    }

    func delete(forKeys: [String]) {

    }

    func delete(forKey key: String) {

    }

    func deleteAll() {

    }

    func leaveTrace() {

    }

    func refreshSessionData() {

    }

    func sessionRefresh() {

    }

    func startNewSession(with sessionStarter: SessionStarterProtocol) {

    }

}
