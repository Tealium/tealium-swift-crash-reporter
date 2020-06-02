//
//  CrashConstants.swift
//  TealiumCrash
//
//  Created by Christina S on 5/1/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation

public enum TealiumCrashKey {
    public static let moduleName = "crash"
    public static let uuid = "crash_uuid"
    public static let processId = "crash_process_id"
    public static let processPath = "crash_process_path"
    public static let parentProcess = "crash_parent_process"
    public static let parentProcessId = "crash_parent_process_id"
    public static let exceptionName = "crash_name"
    public static let exceptionReason = "crash_cause"
    public static let signalCode = "crash_signal_code"
    public static let signalName = "crash_signal_name"
    public static let signalAddress = "crash_signal_address"
    public static let libraries = "crash_libraries"
    public static let threads = "crash_threads"
    public static let deviceMemoryUsageLegacy = "device_memory_usage"
    public static let deviceMemoryUsage = "app_memory_usage"
    public static let deviceMemoryAvailable = "device_memory_available"
    public static let deviceMemoryAvailableLegacy = "memory_free"
    public static let deviceOsBuild = "device_os_build"
    public static let baseAddress = "baseAddress"
    public static let imageName = "imageName"
    public static let imageUuid = "imageUuid"
    public static let imageSize = "imageSize"
    public static let codeType = "codeType"
    public static let architecture = "arch"
    public static let typeEncoding = "typeEncoding"
    
    enum ImageThread: String {
        case baseAddress = "baseAddress"
        case imageName = "imageName"
        case imageUuid = "imageUuid"
        case imageSize = "imageSize"
        case codeType = "codeType"
        case architecture = "arch"
        case typeEncoding = "typeEncoding"
        case registers = "registers"
        case crashed = "crashed"
        case threadId = "threadId"
        case threadNumber = "threadNumber"
        case priority = "priority"
        case stack = "stack"
        case instructionPointer = "instructionPointer"
        case symbolInfo = "symbolInfo"
        case symbolName = "symbolName"
        case symbolStartAddress = "symbolStartAddr"
    }
    
}


