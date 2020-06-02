//
//  TealiumPLCrash.swift
//  TealiumCrash
//
//  Created by Jonathan Wong on 2/12/18.
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

import Foundation
#if !COCOAPODS
import TealiumCore
#endif
import TealiumCrashReporteriOS

public class TealiumPLCrash: TealiumAppDataCollection {

    static let CrashBuildUuid = "CrashBuildUuid"
    static let CrashDataUnknown = "unknown"
    static let CrashEvent = "crash"

    let crashReport: TEALPLCrashReport
    let deviceDataCollection: TealiumDeviceDataCollection
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
    var threadInfos: [TEALPLCrashReportThreadInfo]?
    var images: [TEALPLCrashReportBinaryImageInfo]?

    init(crashReport: TEALPLCrashReport, deviceDataCollection: TealiumDeviceDataCollection) {
        self.crashReport = crashReport
        self.deviceDataCollection = deviceDataCollection
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

        if let images = crashReport.images, crashReport.images as? [TEALPLCrashReportBinaryImageInfo] != nil {
            self.images = images as? [TEALPLCrashReportBinaryImageInfo]
        }

        if let threads = crashReport.threads, !crashReport.threads.isEmpty {
            self.threadInfos = threads as? [TEALPLCrashReportThreadInfo]
        }
    }

    var memoryUsage: String {
        if deviceMemoryUsage == nil {
            deviceMemoryUsage = deviceDataCollection.getMemoryUsage()
        }

        guard let appMemoryUsage = deviceMemoryUsage?[TealiumDeviceDataKey.appMemoryUsage] else {
            return TealiumDeviceDataValue.unknown
        }
        return appMemoryUsage
    }

    var deviceMemoryAvailable: String {
        if deviceMemoryUsage == nil {
            deviceMemoryUsage = deviceDataCollection.getMemoryUsage()
        }
        guard let memoryAvailable = deviceMemoryUsage?[TealiumDeviceDataKey.memoryFree] else {
            return TealiumDeviceDataValue.unknown
        }
        return memoryAvailable
    }

    var osBuild: String {
        let build = TealiumDeviceData.oSBuild()
        guard build != TealiumDeviceDataValue.unknown else {
            if let crashReportBuild = crashReport.systemInfo.operatingSystemBuild {
                return crashReportBuild
            }
            return TealiumPLCrash.CrashDataUnknown
        }

        return build
    }

    func appBuild() -> String {
        guard let appBuild = build(bundle: bundle) else {
            return TealiumDeviceDataValue.unknown
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
                for case let register as TEALPLCrashReportRegisterInfo in registers {
                    registerDictionary[register.registerName] = String(format: "0x%02x", register.registerValue)
                }
            }
            threadDictionary[.registers] = registerDictionary
            threadDictionary[.crashed] = thread.crashed
            threadDictionary[.threadId] = NSNull() // NR: null
            threadDictionary[.priority] = NSNull() // NR: null

            var stackArray = [[String: Any]]()
            var stackDictionary = [String: Any]()
            if let stackFrames = thread.stackFrames, !thread.stackFrames.isEmpty {
                for case let stack as TEALPLCrashReportStackFrameInfo in stackFrames {
                    stackDictionary[.instructionPointer] = stack.instructionPointer
                    var symbolDictionary = [String: Any]()
                    if let symbolInfo = stack.symbolInfo {
                        symbolDictionary[.symbolName] = symbolInfo.symbolName
                        symbolDictionary[.symbolStartAddress] = symbolInfo.startAddress
                    } else {
                        // NR has these values and are required
                        symbolDictionary[.symbolName] = NSNull()
                        symbolDictionary[.symbolStartAddress] = 0
                    }
                    stackDictionary[.symbolInfo] = symbolDictionary
                    stackArray.append(stackDictionary)
                }
            }
            threadDictionary[.stack] = stackArray

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
                formatted[.baseAddress] = String(format: "0x%02x", image.imageBaseAddress)
                codeTypeDictionary[.architecture] = deviceDataCollection.architecture()
                codeTypeDictionary[.typeEncoding] = typeEncoding(image.codeType.typeEncoding)
                formatted[.codeType] = codeTypeDictionary
                formatted[.imageName] = image.imageName
                formatted[.imageUuid] = image.imageUUID
                formatted[.imageSize] = image.imageSize

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
    /// - truncateLibraries: Bool indicating whether the libraries component of the report should be truncated
    /// - truncateThreads: Bool indicating whether the threads component of the report should be truncated
    ///
    /// - Returns: [String: Any] containing all crash-related variables
    public func getData(truncateLibraries: Bool = false, truncateThreads: Bool = false) -> [String: Any] {
            [TealiumKey.event: TealiumPLCrash.CrashEvent,
                TealiumCrashKey.uuid: uuid,
                TealiumCrashKey.deviceMemoryUsageLegacy: memoryUsage,
                TealiumCrashKey.deviceMemoryUsage: memoryUsage,
                TealiumCrashKey.deviceMemoryAvailableLegacy: deviceMemoryAvailable,
                TealiumCrashKey.deviceMemoryAvailable: deviceMemoryAvailable,
                TealiumCrashKey.deviceOsBuild: osBuild,
                TealiumKey.appBuild: appBuild(),
                TealiumCrashKey.processId: processIdentifier ?? TealiumPLCrash.CrashDataUnknown,
                TealiumCrashKey.processPath: processPath ?? TealiumPLCrash.CrashDataUnknown,
                TealiumCrashKey.parentProcess: parentProcessName ?? TealiumPLCrash.CrashDataUnknown,
                TealiumCrashKey.parentProcessId: parentProcessIdentifier ?? TealiumPLCrash.CrashDataUnknown,
                TealiumCrashKey.exceptionName: exceptionName ?? TealiumPLCrash.CrashDataUnknown,
                TealiumCrashKey.exceptionReason: exceptionReason ?? TealiumPLCrash.CrashDataUnknown,
                TealiumCrashKey.signalCode: signalCode ?? TealiumPLCrash.CrashDataUnknown,
                TealiumCrashKey.signalName: signalName ?? TealiumPLCrash.CrashDataUnknown,
                TealiumCrashKey.signalAddress: signalAddress ?? TealiumPLCrash.CrashDataUnknown,
                TealiumCrashKey.libraries: libraries(truncate: truncateLibraries),
                TealiumCrashKey.threads: threads(truncate: truncateThreads)
        ]
    }

    /// Gets all crash-related variables.
    ///
    /// - Parameters:
    /// - truncate: Bool indicating whether the libraries and threads components of the report should be truncated
    ///
    /// - Returns: [String: Any] containing all crash-related variables
    public func getData(truncate: Bool) -> [String: Any] {
        getData(truncateLibraries: truncate, truncateThreads: truncate)
    }
}

fileprivate extension Dictionary where Key: ExpressibleByStringLiteral {
    subscript(key: TealiumCrashKey.ImageThread) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
        set {
            self[key.rawValue as! Key] = newValue
        }
    }
}
