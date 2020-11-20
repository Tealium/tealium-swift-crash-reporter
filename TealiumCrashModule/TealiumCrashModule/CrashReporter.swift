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

// TODO: Try using xcframework and/or updating the targets

/// Defines the specifications for CrashReporterProtocol.  Concrete CrashReporters must implement this protocol.
public protocol CrashReporterProtocol: class {
    @discardableResult
    func enable() -> Bool

    func disable()

    func hasPendingCrashReport() -> Bool

    func purgePendingCrashReport()

    var data: [String: Any]? { get }
}

public class CrashReporter: CrashReporterProtocol {

    var crashReporter = TEALPLCrashReporter()
    public var crashData: [String: Any]?

    public init() {
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
    public var data: [String: Any]? {
        guard crashData == nil else {
            return crashData
        }
        let crashReportData = crashReporter.loadPendingCrashReportData()
        guard let crashReport = try? TEALPLCrashReport(data: crashReportData) else {
            return nil
        }
        let crash = TealiumPLCrash(crashReport: crashReport, deviceDataCollection: DeviceData())
        var data = [String: Any]()
        data += crash.getData(truncate: true)

        return data
    }
}
