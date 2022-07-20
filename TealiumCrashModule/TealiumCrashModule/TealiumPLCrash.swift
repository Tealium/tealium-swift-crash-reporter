//
//  TealiumPLCrash.swift
//  TealiumCrashModule
//
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

import Foundation
#if COCOAPODS
import TealiumSwift
#else
import TealiumCore
#endif
import CrashReporter

public class TealiumPLCrash: AppDataCollection {

    static let CrashBuildUuid = "CrashBuildUuid"
    static let CrashDataUnknown = "unknown"
    static let CrashEvent = "crash"

    let crashReport: PLCrashReport
    let deviceDataCollection: DeviceDataCollection
    private let bundle = Bundle.main

    var uuid: String
    var deviceMemoryUsage: [String: String]?
    var processIdentifier: String?
    var processPath: String?
    var parentProcessName: String?
    var parentProcessIdentifier: String?
    var exceptionName: String?
    var exceptionReason: String?
    var signalCode: String?
    var signalName: String?
    var signalAddress: String?
    var threadInfos: [PLCrashReportThreadInfo]?
    var images: [PLCrashReportBinaryImageInfo]?
    var diskStorage: TealiumDiskStorageProtocol

    init(crashReport: PLCrashReport, deviceDataCollection: DeviceDataCollection, diskStorage: TealiumDiskStorageProtocol) {
        self.crashReport = crashReport
        self.deviceDataCollection = deviceDataCollection
        self.diskStorage = diskStorage
        self.uuid = UUID().uuidString

        if crashReport.hasProcessInfo {
            if let processInfo = crashReport.processInfo {
                self.processIdentifier = String(processInfo.processID)
                self.parentProcessIdentifier = String(processInfo.parentProcessID)
                if let processPath = processInfo.processPath {
                    self.processPath = processPath
                }
                if let parentProcessName = processInfo.parentProcessName {
                    self.parentProcessName = parentProcessName
                }
            }
        }

        if crashReport.hasExceptionInfo {
            if let exceptionInfo = crashReport.exceptionInfo {
                self.exceptionName = exceptionInfo.exceptionName
                self.exceptionReason = exceptionInfo.exceptionReason
            }
        }

        if let signalInfo = crashReport.signalInfo {
            self.signalCode = signalInfo.code
            self.signalName = signalInfo.name
            self.signalAddress = String(signalInfo.address)
        }

        if let images = crashReport.images, crashReport.images as? [PLCrashReportBinaryImageInfo] != nil {
            self.images = images as? [PLCrashReportBinaryImageInfo]
        }

        if let threads = crashReport.threads, !crashReport.threads.isEmpty {
            self.threadInfos = threads as? [PLCrashReportThreadInfo]
        }
    }
    
    var crashCount: Int {
        get {
            diskStorage.getFromDefaults(key: CrashKey.count) as? Int ?? 0
        }
        set {
            diskStorage.saveToDefaults(key: CrashKey.count, value: newValue)
        }
    }

    var memoryUsage: String {
        if deviceMemoryUsage == nil {
            deviceMemoryUsage = deviceDataCollection.memoryUsage
        }

        guard let appMemoryUsage = deviceMemoryUsage?[TealiumDataKey.appMemoryUsage] else {
            return TealiumValue.unknown
        }
        return appMemoryUsage
    }

    var deviceMemoryAvailable: String {
        if deviceMemoryUsage == nil {
            deviceMemoryUsage = deviceDataCollection.memoryUsage
        }
        guard let memoryAvailable = deviceMemoryUsage?[TealiumDataKey.memoryFree] else {
            return TealiumValue.unknown
        }
        return memoryAvailable
    }

    var osBuild: String {
        let build = DeviceData.oSBuild
        guard build != TealiumValue.unknown else {
            if let crashReportBuild = crashReport.systemInfo.operatingSystemBuild {
                return crashReportBuild
            }
            return TealiumPLCrash.CrashDataUnknown
        }

        return build
    }

    func appBuild() -> String {
        guard let appBuild = build(bundle: bundle) else {
            return TealiumValue.unknown
        }
        return appBuild
    }

    func typeEncoding(_ typeEncoding: PLCrashReportProcessorTypeEncoding) -> String {
        switch typeEncoding {
        case PLCrashReportProcessorTypeEncodingMach:
            return "Mach"
        default:
            return TealiumPLCrash.CrashDataUnknown
        }
    }

    /// Provides thread state information.
    ///￼
    /// - Parameter truncate: If enabled, returns just the crashed thread only, otherwise returns all the threads. Default value is false.
    /// - Returns: an array of [String: Any]
    func threads(truncate: Bool = false) -> [[String: Any]] {
        var array = [[String: Any]]()
        guard let threadInfos = threadInfos else {
            return array
        }

        var threadDictionary = [String: Any]()
        for thread in threadInfos {
            var registerDictionary = [String: Any]()
            if let registers = thread.registers, !thread.registers.isEmpty {
                for case let register as PLCrashReportRegisterInfo in registers {
                    registerDictionary[register.registerName] = String(format: "0x%02x", register.registerValue)
                }
            }
            threadDictionary[CrashKey.ImageThread.registers] = registerDictionary
            threadDictionary[CrashKey.ImageThread.crashed] = thread.crashed
            threadDictionary[CrashKey.ImageThread.threadId] = NSNull() // NR: null
            threadDictionary[CrashKey.ImageThread.priority] = NSNull() // NR: null

            var stackArray = [[String: Any]]()
            var stackDictionary = [String: Any]()
            if let stackFrames = thread.stackFrames, !thread.stackFrames.isEmpty {
                for case let stack as PLCrashReportStackFrameInfo in stackFrames {
                    stackDictionary[CrashKey.ImageThread.instructionPointer] = stack.instructionPointer
                    var symbolDictionary = [String: Any]()
                    if let symbolInfo = stack.symbolInfo {
                        symbolDictionary[CrashKey.ImageThread.symbolName] = symbolInfo.symbolName
                        symbolDictionary[CrashKey.ImageThread.symbolStartAddress] = symbolInfo.startAddress
                    } else {
                        // NR has these values and are required
                        symbolDictionary[CrashKey.ImageThread.symbolName] = NSNull()
                        symbolDictionary[CrashKey.ImageThread.symbolStartAddress] = 0
                    }
                    stackDictionary[CrashKey.ImageThread.symbolInfo] = symbolDictionary
                    stackArray.append(stackDictionary)
                }
            }
            threadDictionary[CrashKey.ImageThread.stack] = stackArray

            array.append(threadDictionary)

            if thread.crashed && truncate {
                return [threadDictionary]
            }
        }
        return array
    }

    /// Gets the images that are loaded with the app.
    ///￼
    /// - Parameter truncate: If enabled, returns just the first image loaded, otherwise returns all the images. Default value is false.
    /// - Returns: an array of [String: Any]
    func libraries(truncate: Bool = false) -> [[String: Any]] {
        var array = [[String: Any]]()
        var formatted = [String: Any]()
        var codeTypeDictionary = [String: Any]()
        if let images = images {
            for image in images {
                formatted[CrashKey.ImageThread.baseAddress] = String(format: "0x%02x", image.imageBaseAddress)
                codeTypeDictionary[CrashKey.ImageThread.architecture] = deviceDataCollection.architecture()
                codeTypeDictionary[CrashKey.ImageThread.typeEncoding] = typeEncoding(image.codeType.typeEncoding)
                formatted[CrashKey.ImageThread.codeType] = codeTypeDictionary
                formatted[CrashKey.ImageThread.imageName] = image.imageName
                formatted[CrashKey.ImageThread.imageUuid] = image.imageUUID
                formatted[CrashKey.ImageThread.imageSize] = image.imageSize

                array.append(formatted)

                if truncate {
                    return array
                }
            }
        }
        return array
    }

    /// Gets all crash-related variables.
    ///
    /// - Parameters:
    ///   - truncateLibraries: Bool indicating whether the libraries component of the report should be truncated
    ///   - truncateThreads: Bool indicating whether the threads component of the report should be truncated
    ///
    /// - Returns: [String: Any] containing all crash-related variables
    public func getData(truncateLibraries: Bool = false, truncateThreads: Bool = false) -> [String: Any] {
        crashCount += 1
        return [TealiumDataKey.event: TealiumPLCrash.CrashEvent,
                TealiumDataKey.crashUuid: uuid,
                TealiumDataKey.deviceMemoryUsageLegacy: memoryUsage,
                TealiumDataKey.deviceMemoryUsage: memoryUsage,
                TealiumDataKey.deviceMemoryAvailableLegacy: deviceMemoryAvailable,
                TealiumDataKey.deviceMemoryAvailable: deviceMemoryAvailable,
                TealiumDataKey.deviceOsBuild: osBuild,
                TealiumDataKey.appBuild: appBuild(),
                TealiumDataKey.crashProcessId: processIdentifier ?? TealiumPLCrash.CrashDataUnknown,
                TealiumDataKey.crashProcessPath: processPath ?? TealiumPLCrash.CrashDataUnknown,
                TealiumDataKey.crashParentProcess: parentProcessName ?? TealiumPLCrash.CrashDataUnknown,
                TealiumDataKey.crashParentProcessId: parentProcessIdentifier ?? TealiumPLCrash.CrashDataUnknown,
                TealiumDataKey.crashExceptionName: exceptionName ?? TealiumPLCrash.CrashDataUnknown,
                TealiumDataKey.crashExceptionReason: exceptionReason ?? TealiumPLCrash.CrashDataUnknown,
                TealiumDataKey.crashSignalCode: signalCode ?? TealiumPLCrash.CrashDataUnknown,
                TealiumDataKey.crashSignalName: signalName ?? TealiumPLCrash.CrashDataUnknown,
                TealiumDataKey.crashSignalAddress: signalAddress ?? TealiumPLCrash.CrashDataUnknown,
                TealiumDataKey.crashLibraries: libraries(truncate: truncateLibraries),
                TealiumDataKey.crashThreads: threads(truncate: truncateThreads),
                TealiumDataKey.crashCount: crashCount
        ]
    }

    /// Gets all crash-related variables.
    ///
    /// - Parameters:
    ///   - truncate: Bool indicating whether the libraries and threads components of the report should be truncated
    ///
    /// - Returns: [String: Any] containing all crash-related variables
    public func getData(truncate: Bool) -> [String: Any] {
        getData(truncateLibraries: truncate, truncateThreads: truncate)
    }
}
