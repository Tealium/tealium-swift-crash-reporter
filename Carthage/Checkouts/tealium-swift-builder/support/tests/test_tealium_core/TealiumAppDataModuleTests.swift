//
//  TealiumAppDataModuleTests.swift
//  tealium-swift
//
//  Created by Christina S on 05/20/20.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

@testable import TealiumCore
import XCTest

class TealiumAppDataModuleTests: XCTestCase {

    var appDataModule: TealiumAppDataModule?
    let mockDiskStorage = MockAppDataDiskStorage()

    override func setUp() {
        appDataModule = TealiumAppDataModule(config: TestTealiumHelper().getConfig(), delegate: self, diskStorage: mockDiskStorage, bundle: Bundle(for: type(of: self)))
    }

    func testInitSetsExistingAppData() {
        XCTAssertEqual(mockDiskStorage.retrieveCount, 1)
        guard let data = appDataModule?.data, let visId = data[TealiumKey.visitorId] as? String else {
            XCTFail("Nothing in persistent app data and there should be a test visitor id.")
            return
        }
        XCTAssertEqual(visId, "someVisitorId")
    }

    func testDeleteAllData() {
        appDataModule?.deleteAllData()
        XCTAssertEqual(mockDiskStorage.deleteCount, 1)
    }

    func testIsMissingPersistentKeys() {
        let missingUUID = [TealiumKey.visitorId: "someVisitorId"]
        XCTAssertTrue(TealiumAppDataModule.isMissingPersistentKeys(data: missingUUID))
        let missingVisitorID = [TealiumKey.uuid: "someUUID"]
        XCTAssertTrue(TealiumAppDataModule.isMissingPersistentKeys(data: missingVisitorID))
        let neitherMissing = [TealiumKey.visitorId: "someVisitorId", TealiumKey.uuid: "someUUID"]
        XCTAssertFalse(TealiumAppDataModule.isMissingPersistentKeys(data: neitherMissing))
    }

    func testVisitorIdFromUUID() {
        let uuid = UUID().uuidString
        guard let visitorId = appDataModule?.visitorId(from: uuid) else {
            XCTFail("Visitor id should not be null")
            return
        }
        XCTAssertTrue(!visitorId.contains("-"))
    }

    func testNewPersistentData() {
        let uuid = UUID().uuidString
        let data = appDataModule?.newPersistentData(for: uuid)
        XCTAssertEqual(mockDiskStorage.saveToDefaultsCount, 1)
        XCTAssertEqual(mockDiskStorage.saveCount, 1)
        XCTAssertEqual(data?.dictionary.keys.sorted(), [TealiumKey.visitorId, TealiumKey.uuid].sorted())
    }

    func testNewVolatileData() {
        appDataModule?.newVolatileData()
        guard let appData = appDataModule?.appData else {
            XCTFail("AppData should not be nil")
            return
        }
        #if os(iOS)
        XCTAssertEqual(appData.name, "TealiumCoreTests-iOS")
        #elseif os(macOS)
        XCTAssertEqual(appData.name, "TealiumCoreTests-macOS")
        #elseif os(tvOS)
        XCTAssertEqual(appData.name, "TealiumCoreTests-tvOS")
        #endif
        XCTAssertEqual(appData.rdns, "com.tealium.TealiumTests")
        XCTAssertEqual(appData.version, "1.0")
        XCTAssertEqual(appData.build, "1")
    }

    func testSetNewAppData() {
        appDataModule?.setNewAppData()
        XCTAssertEqual(mockDiskStorage.saveToDefaultsCount, 1)
        XCTAssertEqual(mockDiskStorage.saveCount, 1)
        XCTAssertNotNil(appDataModule?.appData.persistentData?.visitorId)
        XCTAssertNotNil(appDataModule?.appData.persistentData?.uuid)
    }

    func testSetLoadedAppData() {
        let config = TestTealiumHelper().getConfig()
        config.existingVisitorId = "someOtherVisitorId"
        let module = TealiumAppDataModule(config: config, delegate: self, diskStorage: mockDiskStorage, bundle: Bundle(for: type(of: self)))
        let testPersistentData = PersistentAppData(visitorId: "someVisitorId", uuid: "someUUID")
        module.setLoadedAppData(data: testPersistentData)
        // 2x because of init in setUp
        XCTAssertEqual(mockDiskStorage.saveToDefaultsCount, 2)
        XCTAssertEqual(mockDiskStorage.saveCount, 2)
        guard let appData = appDataModule?.appData else {
            XCTFail("AppData should not be nil")
            return
        }
        XCTAssertNotNil(appData.name)
        XCTAssertNotNil(appData.rdns)
        XCTAssertNotNil(appData.build)
    }

    func testPersistentDataInitFromDictionary() {
        let data = [TealiumKey.visitorId: "someVisitorId", TealiumKey.uuid: "someUUID"]
        let persistentData = PersistentAppData.initFromDictionary(data)
        XCTAssertEqual(persistentData?.visitorId, "someVisitorId")
        XCTAssertEqual(persistentData?.uuid, "someUUID")
    }

    func testAppDataDictionary() {
        let appDataDict = appDataModule?.appData.dictionary
        XCTAssertNotNil(appDataDict?[TealiumKey.appName])
        XCTAssertNotNil(appDataDict?[TealiumKey.appRDNS])
        XCTAssertNotNil(appDataDict?[TealiumKey.visitorId])
        XCTAssertNotNil(appDataDict?[TealiumKey.uuid])
    }

}

extension TealiumAppDataModuleTests: TealiumModuleDelegate {
    func requestTrack(_ track: TealiumTrackRequest) {

    }

    func requestReleaseQueue(reason: String) {

    }

}
