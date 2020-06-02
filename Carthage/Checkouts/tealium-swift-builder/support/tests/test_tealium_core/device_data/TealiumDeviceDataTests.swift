//
//  TealiumDeviceDataTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 8/1/17.
//  Copyright © 2017 Tealium, Inc. All rights reserved.
//

@testable import TealiumCore
import XCTest
#if canImport(UIKit)
import UIKit
#endif

class TealiumDeviceDataTests: XCTestCase {

    var deviceData: TealiumDeviceData {
        let config = testTealiumConfig.copy
        config.memoryReportingEnabled = true
        return TealiumDeviceData()
    }
    
    var deviceDataCollector: DeviceDataModule {
        let config = testTealiumConfig.copy
        config.memoryReportingEnabled = true
        return DeviceDataModule(config: config, delegate: nil, diskStorage: nil, completion: { result in })
    }
    
    var deviceDataCollectorMemoryDisabled: DeviceDataModule {
        let config = testTealiumConfig.copy
        config.memoryReportingEnabled = false
        return DeviceDataModule(config: config, delegate: nil, diskStorage: nil, completion: { result in })
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBatteryPercent() {
        let percent = TealiumDeviceData.batteryPercent()
        #if os (iOS)
        #if targetEnvironment(simulator)
        XCTAssertEqual(percent, "-100.0")
        #else
        XCTAssertNotEqual(percent, "-100.0")
        XCTAssertNotEqual(percent, "")
        #endif
        #else
        XCTAssertEqual(percent, TealiumDeviceDataValue.unknown)
        #endif
    }
    
    func testIsCharging() {
        let isCharging = TealiumDeviceData.isCharging()
        #if os (iOS)
        #if targetEnvironment(simulator)
        XCTAssertEqual(isCharging, "unknown")
        #else
        XCTAssertNotEqual(isCharging, "unknown")
        #endif
        #else
        XCTAssertEqual(isCharging, TealiumDeviceDataValue.unknown)
        #endif
    }
    
    func testCPUType() {
        let cpu = deviceData.cpuType()
        #if targetEnvironment(simulator)
        XCTAssertEqual(cpu, "x86")
        #elseif os(OSX)
        XCTAssertEqual(cpu, "x86")
        #else
        XCTAssertNotEqual(cpu, "x86")
        #endif
        XCTAssertNotEqual(cpu, TealiumDeviceDataValue.unknown)
    }
    
    func testIsoLanguage() {
        let isoLanguage = TealiumDeviceData.iso639Language()
        XCTAssertTrue(isoLanguage.starts(with: "en"))
    }
    
    func testResolution() {
        let resolution = TealiumDeviceData.resolution()
        #if os(OSX)
        XCTAssertEqual(resolution, TealiumDeviceDataValue.unknown)
        #else
        let res = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let width = res.width * scale
        let height = res.height * scale
        let stringRes = String(format: "%.0fx%.0f", height, width)
        XCTAssertEqual(stringRes, resolution)
        #endif
    }
    
    func testOrientation() {
        let orientation = deviceData.orientation()
        #if os(iOS)
        #if targetEnvironment(simulator)
        XCTAssertEqual([TealiumDeviceDataKey.orientation: "Portrait",
                TealiumDeviceDataKey.fullOrientation: "Portrait"
        ], orientation)
        #else
        XCTAssertEqual([TealiumDeviceDataKey.orientation: "Portrait",
                TealiumDeviceDataKey.fullOrientation: "Face Up"
        ], orientation)
        #endif
        #else
        XCTAssertEqual([TealiumDeviceDataKey.orientation: TealiumDeviceDataValue.unknown,
                TealiumDeviceDataKey.fullOrientation: TealiumDeviceDataValue.unknown
        ], orientation)
        #endif
    }
    
    func testOSBuild() {
        XCTAssertEqual(TealiumDeviceData.oSBuild(), Bundle.main.infoDictionary?["DTSDKBuild"] as! String)
    }
    
    func testOSVersion() {
        let osVersion = TealiumDeviceData.oSVersion()
        #if os(iOS)
        XCTAssertEqual(osVersion, UIDevice.current.systemVersion)
        #elseif os(OSX)
        XCTAssertEqual(osVersion, ProcessInfo.processInfo.operatingSystemVersionString)
        #elseif os(tvOS)
        XCTAssertEqual(osVersion, UIDevice.current.systemVersion)
        #endif
        XCTAssertNotEqual(osVersion, TealiumDeviceDataValue.unknown)
    }
    
    func testOSName() {
        let osName = TealiumDeviceData.oSName()
        #if os(iOS)
        XCTAssertEqual(osName, "iOS")
        #elseif os(OSX)
        XCTAssertEqual(osName, "macOS")
        #elseif os(tvOS)
        XCTAssertEqual(osName, "tvOS")
        #endif
        XCTAssertNotEqual(osName, TealiumDeviceDataValue.unknown)
    }
    
    func testCarrierInfo() {
        let simulatorCarrierInfo = [
            TealiumDeviceDataKey.carrierMNC: "00",
            TealiumDeviceDataKey.carrierMCC: "000",
            TealiumDeviceDataKey.carrierISO: "us",
            TealiumDeviceDataKey.carrier: "simulator",
            TealiumDeviceDataKey.carrierMNCLegacy: "00",
            TealiumDeviceDataKey.carrierMCCLegacy: "000",
            TealiumDeviceDataKey.carrierISOLegacy: "us",
            TealiumDeviceDataKey.carrierLegacy: "simulator"
        ]
        
        let retrievedCarrierInfo = TealiumDeviceData.carrierInfo()
        #if os(iOS)
        #if targetEnvironment(simulator)
        XCTAssertEqual(simulatorCarrierInfo, retrievedCarrierInfo)
        #else
        XCTAssertNotEqual("", retrievedCarrierInfo[TealiumDeviceDataKey.carrierMNC]!)
        XCTAssertNotEqual("", retrievedCarrierInfo[TealiumDeviceDataKey.carrierMCC]!)
        XCTAssertNotEqual("", retrievedCarrierInfo[TealiumDeviceDataKey.carrierISO]!)
        XCTAssertNotEqual("", retrievedCarrierInfo[TealiumDeviceDataKey.carrier]!)
        XCTAssertNotEqual("", retrievedCarrierInfo[TealiumDeviceDataKey.carrierMNCLegacy]!)
        XCTAssertNotEqual("", retrievedCarrierInfo[TealiumDeviceDataKey.carrierMCCLegacy]!)
        XCTAssertNotEqual("", retrievedCarrierInfo[TealiumDeviceDataKey.carrierISOLegacy]!)
        XCTAssertNotEqual("", retrievedCarrierInfo[TealiumDeviceDataKey.carrierLegacy]!)
        #endif
        #endif
    }
    
    func testModel() {
        let basicModel = deviceData.basicModel()
        let fullModel = deviceData.model()
        #if os(OSX)
        XCTAssertEqual(basicModel, "x86_64")
        XCTAssertEqual(fullModel["device_type"]!, "x86_64")
        XCTAssertEqual(fullModel["model_name"]!, "mac")
        XCTAssertEqual(fullModel["device"]!, "mac")
        XCTAssertEqual(fullModel["model_variant"]!, "mac")
        #else
        
        #if targetEnvironment(simulator)
        XCTAssertEqual("x86_64", basicModel)
        XCTAssertEqual(fullModel, ["device_type": "x86_64",
                                   "model_name": "Simulator",
                                   "device": "Simulator",
                                   "model_variant": "64-bit"])
        #else
        XCTAssertNotEqual("x86_64", basicModel)
        XCTAssertNotEqual("", basicModel)
        XCTAssertNotEqual(fullModel["device_type"]!, "x86_64")
        XCTAssertNotEqual(fullModel["device_type"]!, "")
        
        XCTAssertNotEqual(fullModel["model_name"]!, "Simulator")
        XCTAssertNotEqual(fullModel["model_name"]!, "")
        
        XCTAssertNotEqual(fullModel["device"]!, "Simulator")
        XCTAssertNotEqual(fullModel["device"]!, "")
        
        XCTAssertNotEqual(fullModel["model_variant"]!, "64-bit")
        XCTAssertNotEqual(fullModel["model_variant"]!, "")
        #endif
        #endif
    }
    
    func testGetMemoryUsage() {
        let memoryUsage = deviceData.getMemoryUsage()
        XCTAssertNotEqual(memoryUsage["memory_free"]!, "")
        XCTAssertNotEqual(memoryUsage["memory_inactive"]!, "")
        
        XCTAssertNotEqual(memoryUsage["memory_wired"]!, "")
        XCTAssertNotEqual(memoryUsage["memory_active"]!, "")
        
        XCTAssertNotEqual(memoryUsage["memory_compressed"]!, "")
        XCTAssertNotEqual(memoryUsage["memory_physical"]!, "")
        
        XCTAssertNotEqual(memoryUsage["app_memory_usage"]!, "")
    }
    
    func testDeviceDataCollectorMemoryEnabled() {
        let collector = deviceDataCollector
        let data = collector.data as! [String: String]
        XCTAssertNotEqual(data["memory_free"]!, "")
        XCTAssertNotEqual(data["memory_inactive"]!, "")
        XCTAssertNotEqual(data["memory_wired"]!, "")
        XCTAssertNotEqual(data["memory_active"]!, "")
        XCTAssertNotEqual(data["memory_compressed"]!, "")
        XCTAssertNotEqual(data["memory_physical"]!, "")
        XCTAssertNotEqual(data["app_memory_usage"]!, "")
        XCTAssertNotEqual(data["cpu_architecture"]!, "")
        XCTAssertNotEqual(data["device_architecture"]!, "")
        XCTAssertNotEqual(data["os_build"]!, "")
        XCTAssertNotEqual(data["device_os_build"]!, "")
        XCTAssertNotEqual(data["cpu_type"]!, "")
        XCTAssertNotEqual(data["device_cputype"]!, "")
        XCTAssertNotEqual(data["device_type"]!, "")
        XCTAssertNotEqual(data["model_name"]!, "")
        XCTAssertNotEqual(data["device"]!, "")
        XCTAssertNotEqual(data["model_variant"]!, "")
        XCTAssertNotEqual(data["os_version"]!, "")
        XCTAssertNotEqual(data["device_os_version"]!, "")
        XCTAssertNotEqual(data["os_name"]!, "")
        XCTAssertNotEqual(data["platform"]!, "")
        XCTAssertNotEqual(data["device_resolution"]!, "")
        XCTAssertNotEqual(data["battery_percent"]!, "")
        XCTAssertNotEqual(data["device_battery_percent"]!, "")
        XCTAssertNotEqual(data["device_is_charging"]!, "")
        XCTAssertNotEqual(data["device_language"]!, "")
        XCTAssertNotEqual(data["user_locale"]!, "")
        XCTAssertNotEqual(data["device_orientation"]!, "")
        XCTAssertNotEqual(data["device_orientation_extended"]!, "")
        #if os(iOS)
        XCTAssertNotEqual(data["carrier_mnc"]!, "")
        XCTAssertNotEqual(data["carrier_mcc"]!, "")
        XCTAssertNotEqual(data["carrier_iso"]!, "")
        XCTAssertNotEqual(data["carrier"]!, "")
        XCTAssertNotEqual(data["network_mnc"]!, "")
        XCTAssertNotEqual(data["network_mcc"]!, "")
        XCTAssertNotEqual(data["network_iso_country_code"]!, "")
        XCTAssertNotEqual(data["network_name"]!, "")
        #endif
    }
    
    func testDeviceDataCollectorMemoryDisabled() {
        let collector = deviceDataCollectorMemoryDisabled
        let data = collector.data as! [String: String]
        XCTAssertNil(data["memory_free"])
        XCTAssertNil(data["memory_inactive"])
        XCTAssertNil(data["memory_wired"])
        XCTAssertNil(data["memory_active"])
        XCTAssertNil(data["memory_compressed"])
        XCTAssertNil(data["memory_physical"])
        XCTAssertNil(data["app_memory_usage"])
    }
}
