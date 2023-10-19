//
//  CrashModule.swift
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

public class CrashModule: Collector {

    public let id: String = ModuleNames.crash
    var crashReporter: CrashReporterProtocol?
    weak var delegate: ModuleDelegate?
    var diskStorage: TealiumDiskStorageProtocol!
    public var config: TealiumConfig

    public var data: [String: Any]? = [:]

    /// Provided for unit testing￼.
    ///
    /// - Parameters:
    ///   - config: `TealiumConfig` instance
    ///   - delegate: `TealiumModuleDelegate` instance
    ///   - diskStorage: `TealiumDiskStorageProtocol` instance
    ///   - crashReporter: Class instance conforming to `CrashReporterProtocol`
    init(context: TealiumContext,
         delegate: ModuleDelegate?,
         diskStorage: TealiumDiskStorageProtocol?,
         crashReporter: CrashReporterProtocol) {
        self.delegate = delegate
        self.config = context.config
        self.crashReporter = crashReporter
        if self.crashReporter?.hasPendingCrashReport() == true {
            if context.config.sendCrashDataOnCrashDetected {
                delegate?.requestTrack(TealiumEvent(TealiumKey.crashEvent,
                                                    dataLayer: crashReporter.data).trackRequest)
            } else {
                self.data = crashReporter.data
            }
            self.crashReporter?.purgePendingCrashReport()
        }
    }

    /// Initializes the module
    ///
    /// - Parameters:
    ///   - config: `TealiumConfig` instance
    ///   - delegate: `TealiumModuleDelegate` instance
    ///   - diskStorage: `TealiumDiskStorageProtocol` instance
    ///   - completion: `ModuleCompletion` block to be called when init is finished
    required convenience public init(context: TealiumContext,
                         delegate: ModuleDelegate?,
                         diskStorage: TealiumDiskStorageProtocol?,
                         completion: ((Result<Bool, Error>, [String : Any]?)) -> Void) {
        let diskStorage = diskStorage ?? TealiumDiskStorage(config: context.config, forModule: "crash", isCritical: true)
        self.init(context: context,
                  delegate: delegate,
                  diskStorage: diskStorage,
                  crashReporter: CrashReporter(diskStorage: diskStorage))
        completion((.success(true), nil))
    }

}
