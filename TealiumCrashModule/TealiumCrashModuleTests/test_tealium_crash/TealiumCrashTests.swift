//
//  TealiumCrashTests.swift
//  TealiumCrashModule
//
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

import TealiumCore
@testable import TealiumCrashModule
@testable import CrashReporter
import XCTest

class TealiumCrashTests: XCTestCase {

    var mockTimestampCollection: TimestampCollection!
    var mockAppDataCollection: AppDataCollection!
    var mockDeviceDataCollection: DeviceDataCollection!
    var mockDiskStorage = MockDiskStorage()

    override func setUp() {
        super.setUp()
        mockTimestampCollection = MockTimestampCollection()
        mockAppDataCollection = MockTealiumAppDataCollection()
        mockDeviceDataCollection = MockDeviceDataCollection()
    }

    override func tearDown() {
        mockTimestampCollection = nil
        mockAppDataCollection = nil
        mockDeviceDataCollection = nil
        super.tearDown()
    }

    func testCrashUuidNotNil() {
        let crashReport = PLCrashReport()
        let crash = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: mockDeviceDataCollection, diskStorage: mockDiskStorage)

        XCTAssertNotNil(crash.uuid, "crash.uuid should not be nil")
    }

    func testCrashUuidsUnique() {
        let crashReport = PLCrashReport()
        let crash1 = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: mockDeviceDataCollection, diskStorage: mockDiskStorage)
        let crash2 = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: mockDeviceDataCollection, diskStorage: mockDiskStorage)

        XCTAssertNotEqual(crash1.uuid, crash2.uuid, "crash.uuid should be unique between crash instances")
    }

    func testMemoryUsageReturnsUnknownIfAppMemoryUsageIsNil() {
        let crashReport = PLCrashReport()
        let crash = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: mockDeviceDataCollection, diskStorage: mockDiskStorage)

        XCTAssertEqual(TealiumValue.unknown, crash.memoryUsage)
    }

    func testMemoryAvailableReturnsUnknownIfMemoryFreeIsNil() {
        let crashReport = PLCrashReport()
        let crash = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: mockDeviceDataCollection, diskStorage: mockDiskStorage)

        XCTAssertEqual(TealiumValue.unknown, crash.deviceMemoryAvailable)
    }

    func testThreadsReturnsCrashedIfTruncated() {
        let testBundle = Bundle(for: type(of: self))
        if let url = testBundle.url(forResource: "index_out_of_bounds", withExtension: "plcrash") {
            do {
                let data = try Data(contentsOf: url, options: Data.ReadingOptions.mappedRead)
                let crashReport = try PLCrashReport(data: data)
                let crash = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: mockDeviceDataCollection, diskStorage: mockDiskStorage)
                let result = crash.threads(truncate: true)
                XCTAssertEqual(1, result.count)
            } catch _ {
                XCTFail("Error running test")
            }
        }
    }

    func testLibrariesReturnsFirstLibraryIfTruncated() {
        let testBundle = Bundle(for: type(of: self))
        if let url = testBundle.url(forResource: "index_out_of_bounds", withExtension: "plcrash") {
            do {
                let data = try Data(contentsOf: url, options: Data.ReadingOptions.mappedRead)
                let crashReport = try PLCrashReport(data: data)
                let crash = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: mockDeviceDataCollection, diskStorage: mockDiskStorage)
                let result = crash.libraries(truncate: true)
                XCTAssertEqual(1, result.count)
            } catch _ {
                XCTFail("Error running test")
            }
        }
    }

    func testGetDataCrashKeys() {
        let testBundle = Bundle(for: type(of: self))
        if let url = testBundle.url(forResource: "live_report", withExtension: "plcrash") {
            do {
                let data = try Data(contentsOf: url, options: Data.ReadingOptions.mappedRead)
                let crashReport = try PLCrashReport(data: data)
                let crash = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: mockDeviceDataCollection, diskStorage: mockDiskStorage)
                let expectedKeys = [TealiumDataKey.event,
                                    CrashKey.uuid,
                                    CrashKey.deviceMemoryUsage,
                                    CrashKey.deviceMemoryAvailable,
                                    CrashKey.deviceOsBuild,
                                    TealiumDataKey.appBuild,
                                    CrashKey.processId,
                                    CrashKey.processPath,
                                    CrashKey.parentProcess,
                                    CrashKey.parentProcessId,
                                    CrashKey.exceptionName,
                                    CrashKey.exceptionReason,
                                    CrashKey.signalCode,
                                    CrashKey.signalName,
                                    CrashKey.signalAddress,
                                    CrashKey.libraries,
                                    CrashKey.threads,
                                    CrashKey.count
                ]
                let result = crash.getData()
                for key in expectedKeys {
                    print(key)
                    XCTAssertNotNil(result[key])
                }
            } catch _ {
                XCTFail("Error running test")
            }
        }
    }
    
    func testCrashCount_Incremented_WhenCrashReportExists() {
        let testBundle = Bundle(for: type(of: self))
        if let url = testBundle.url(forResource: "live_report", withExtension: "plcrash") {
            do {
                let data = try Data(contentsOf: url, options: Data.ReadingOptions.mappedRead)
                let crashReport = try PLCrashReport(data: data)
                let crash = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: mockDeviceDataCollection, diskStorage: mockDiskStorage)

                _ = crash.getData()
                XCTAssertEqual(1, mockDiskStorage.crashCount)
                
                _ = crash.getData()
                XCTAssertEqual(2, mockDiskStorage.crashCount)
                
            } catch _ {
                XCTFail("Error running test")
            }
        }
    }
    
}

public class MockDeviceDataCollection: DeviceDataCollection {
    public var orientation: [String: String] {
        return orientationDictionary
    }

    public var model: [String: String] {
        return modelDictionary
    }

    public var basicModel: String {
        basicModelProperty
    }

    public var cpuType: String {
        architecture
    }

    public var memoryUsage = [String: String]()
    var orientationDictionary = [String: String]()
    var modelDictionary = [String: String]()
    var basicModelProperty = ""
    var architecture: String = ""

    public func getMemoryUsage() -> [String: String] {
        return memoryUsage
    }
}

class MockTimestampCollection: TimestampCollection {
    var currentTimeStamps: [String: Any] {
        ["test": "1"]
    }
}

class MockTealiumAppDataCollection: AppDataCollection {
    var uuid: String?
    var appName: String?
    var appVersion: String?
    var appRdns: String?
    var appBuild: String?

    func name() -> String? {
        return appName
    }

    func rdns() -> String? {
        return appRdns
    }

    func version() -> String? {
        return appVersion
    }

    func build() -> String? {
        return appBuild
    }
}

class MockDiskStorage: TealiumDiskStorageProtocol {
    
    public var crashCount = 0
    
    func save(_ data: AnyCodable, completion: TealiumCompletion?) {
    }
    
    func save(_ data: AnyCodable, fileName: String, completion: TealiumCompletion?) {
    }
    
    func save<T>(_ data: T, completion: TealiumCompletion?) where T : Encodable {
    }
    
    func save<T>(_ data: T, fileName: String, completion: TealiumCompletion?) where T : Encodable {
    }
    
    func append<T>(_ data: T, completion: TealiumCompletion?) where T : Decodable, T : Encodable {
    }
    
    func append<T>(_ data: T, fileName: String, completion: TealiumCompletion?) where T : Decodable, T : Encodable {
    }
    
    func append(_ data: [String : Any], fileName: String, completion: TealiumCompletion?) {
    }
    
    func retrieve<T>(as type: T.Type) -> T? where T : Decodable {
        nil
    }
    
    func retrieve<T>(_ fileName: String, as type: T.Type) -> T? where T : Decodable {
        nil
    }
    
    func retrieve(fileName: String, completion: (Bool, [String : Any]?, Error?) -> Void) {
    }
    
    func update<T>(value: Any, for key: String, as type: T.Type, completion: TealiumCompletion?) where T : Decodable, T : Encodable {
    }
    
    func delete(completion: TealiumCompletion?) {
    }
    
    func totalSizeSavedData() -> String? {
        nil
    }
    
    func saveStringToDefaults(key: String, value: String) {
    }
    
    func getStringFromDefaults(key: String) -> String? {
        nil
    }
    
    func saveToDefaults(key: String, value: Any) {
        guard let value = value as? Int else { return }
        crashCount = value
    }
    
    func getFromDefaults(key: String) -> Any? {
        crashCount
    }
    
    func removeFromDefaults(key: String) {
    }
    
    func canWrite() -> Bool {
        false
    }
    
    
}
