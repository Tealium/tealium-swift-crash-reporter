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

    public var data: [String: Any]? {
        self.crashReporter?.data
    }

    /// Provided for unit testing￼.
    ///
    /// - Parameters:
    ///   - config: `TealiumConfig` instance
    ///   - delegate: `TealiumModuleDelegate` instance
    ///   - diskStorage: `TealiumDiskStorageProtocol` instance
    ///   - crashReporter: Class instance conforming to `CrashReporterProtocol`
    convenience init(context: TealiumContext,
                     delegate: ModuleDelegate?,
                     diskStorage: TealiumDiskStorageProtocol?,
                      crashReporter: CrashReporterProtocol) {
        self.init(context: context, delegate: delegate, diskStorage: diskStorage) { _ in }
        self.crashReporter = crashReporter
    }

    /// Initializes the module
    ///
    /// - Parameters:
    ///   - config: `TealiumConfig` instance
    ///   - delegate: `TealiumModuleDelegate` instance
    ///   - diskStorage: `TealiumDiskStorageProtocol` instance
    ///   - completion: `ModuleCompletion` block to be called when init is finished
    required public init(context: TealiumContext,
                         delegate: ModuleDelegate?,
                         diskStorage: TealiumDiskStorageProtocol?,
                         completion: ((Result<Bool, Error>, [String : Any]?)) -> Void) {
        self.delegate = delegate
        self.config = context.config
        self.diskStorage = diskStorage ?? TealiumDiskStorage(config: config, forModule: "crash", isCritical: true)
        self.crashReporter = CrashReporter(diskStorage: self.diskStorage)
        completion((.success(true), nil))
    }

}
