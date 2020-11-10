//
//  TealiumPLCrash.swift
//  TealiumCrash
//
//  Created by Jonathan Wong on 2/12/18.
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

import Foundation
#if COCOAPODS
import TealiumSwift
#else
import TealiumCore
#endif
import TealiumCrashReporteriOS

public class TealiumPLCrash: AppDataCollection {

    static let CrashBuildUuid = "CrashBuildUuid"
    static let CrashDataUnknown = "unknown"
    static let CrashEvent = "crash"

    let crashReport: TEALPLCrashReport
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
    var threadInfos: [TEALPLCrashReportThreadInfo]?
    var images: [TEALPLCrashReportBinaryImageInfo]?

    init(crashReport: TEALPLCrashReport, deviceDataCollection: DeviceDataCollection) {
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
            deviceMemoryUsage = deviceDataCollection.memoryUsage
        }

        guard let appMemoryUsage = deviceMemoryUsage?[DeviceDataKey.appMemoryUsage] else {
            return TealiumValue.unknown
        }
        return appMemoryUsage
    }

    var deviceMemoryAvailable: String {
        if deviceMemoryUsage == nil {
            deviceMemoryUsage = deviceDataCollection.memoryUsage
        }
        guard let memoryAvailable = deviceMemoryUsage?[DeviceDataKey.memoryFree] else {
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
                for case let register as TEALPLCrashReportRegisterInfo in registers {
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
                for case let stack as TEALPLCrashReportStackFrameInfo in stackFrames {
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
        [TealiumKey.event: TealiumPLCrash.CrashEvent,
         CrashKey.uuid: uuid,
         CrashKey.deviceMemoryUsageLegacy: memoryUsage,
         CrashKey.deviceMemoryUsage: memoryUsage,
         CrashKey.deviceMemoryAvailableLegacy: deviceMemoryAvailable,
         CrashKey.deviceMemoryAvailable: deviceMemoryAvailable,
         CrashKey.deviceOsBuild: osBuild,
         TealiumKey.appBuild: appBuild(),
         CrashKey.processId: processIdentifier ?? TealiumPLCrash.CrashDataUnknown,
         CrashKey.processPath: processPath ?? TealiumPLCrash.CrashDataUnknown,
         CrashKey.parentProcess: parentProcessName ?? TealiumPLCrash.CrashDataUnknown,
         CrashKey.parentProcessId: parentProcessIdentifier ?? TealiumPLCrash.CrashDataUnknown,
         CrashKey.exceptionName: exceptionName ?? TealiumPLCrash.CrashDataUnknown,
         CrashKey.exceptionReason: exceptionReason ?? TealiumPLCrash.CrashDataUnknown,
         CrashKey.signalCode: signalCode ?? TealiumPLCrash.CrashDataUnknown,
         CrashKey.signalName: signalName ?? TealiumPLCrash.CrashDataUnknown,
         CrashKey.signalAddress: signalAddress ?? TealiumPLCrash.CrashDataUnknown,
         CrashKey.libraries: libraries(truncate: truncateLibraries),
         CrashKey.threads: threads(truncate: truncateThreads)
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
