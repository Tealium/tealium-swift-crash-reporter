//
//  CrashExtensions.swift
//  TealiumCrashModule
//
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation
#if COCOAPODS
import TealiumSwift
#else
import TealiumCore
#endif


public extension Collectors {
    static let Crash = CrashModule.self
}

public extension TealiumDataKey {
    static let crashUuid = "crash_uuid"
    static let deviceMemoryUsageLegacy = "device_memory_usage"
    static let deviceMemoryUsage = "app_memory_usage"
    static let deviceMemoryAvailableLegacy = "memory_free"
    static let deviceMemoryAvailable = "device_memory_available"
    static let deviceOsBuild = "device_os_build"
    static let crashProcessId = "crash_process_id"
    static let crashProcessPath = "crash_process_path"
    static let crashParentProcess = "crash_parent_process"
    static let crashParentProcessId = "crash_parent_process_id"
    static let crashExceptionName = "crash_name"
    static let crashExceptionReason = "crash_cause"
    static let crashSignalCode = "crash_signal_code"
    static let crashSignalName = "crash_signal_name"
    static let crashSignalAddress = "crash_signal_address"
    static let crashLibraries = "crash_libraries"
    static let crashThreads = "crash_threads"
    static let crashCount = "crash_count"
}

public extension TealiumConfig {
    var sendCrashDataOnCrashDetected: Bool {
        get {
            options[TealiumConfigKey.sendCrashDataOnCrashDetected] as? Bool ?? false
        }
        set {
            options[TealiumConfigKey.sendCrashDataOnCrashDetected] = newValue
        }
    }
}

extension TealiumConfigKey {
    static let sendCrashDataOnCrashDetected = "send_crash_data_on_detected_event"
}

extension TealiumKey {
    static let crashEvent = "crash"
}
