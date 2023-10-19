//
//  CrashReporter.swift
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

/// Defines the specifications for CrashReporterProtocol.  Concrete CrashReporters must implement this protocol.
public protocol CrashReporterProtocol: AnyObject {
    @discardableResult
    func enable() -> Bool

    func disable()

    func hasPendingCrashReport() -> Bool

    func purgePendingCrashReport()

    var data: [String: Any]? { get }
}

public class CrashReporter: CrashReporterProtocol {

    var crashReporter = PLCrashReporter()
    var diskStorage: TealiumDiskStorageProtocol

    public init(diskStorage: TealiumDiskStorageProtocol) {
        self.diskStorage = diskStorage
        self.enable()
    }

    @discardableResult
    public func enable() -> Bool {
        return crashReporter.enable()
    }

    /// Checks if a crash report exists.
    public func hasPendingCrashReport() -> Bool {
        return crashReporter.hasPendingCrashReport()
    }

    /// Removes any existing crash report on `disable()`.
    public func disable() {
        crashReporter.purgePendingCrashReport()
    }

    /// Removes any existing crash report.
    public func purgePendingCrashReport() {
        crashReporter.purgePendingCrashReport()
    }

    /// Invokes a crash￼.
    ///
    /// - Parameter name: `String` name of the crash￼
    /// - Parameter reason: `String` reason for the crash
    public class func invokeCrash(name: String, reason: String) {
        NSException(name: NSExceptionName(rawValue: name), reason: reason, userInfo: nil).raise()
    }

    /// Gets crash data if crash module is enabled.
    ///
    /// - Returns: `[String: Any]` containing crash information
    lazy public private(set) var data: [String: Any]? = {
        let crashReportData = crashReporter.loadPendingCrashReportData()
        guard let crashReport = try? PLCrashReport(data: crashReportData) else {
            return nil
        }
        let crash = TealiumPLCrash(crashReport: crashReport,
                                   deviceDataCollection: DeviceData(),
                                   diskStorage: diskStorage)
        return crash.getData(truncate: true)
    }()
}
