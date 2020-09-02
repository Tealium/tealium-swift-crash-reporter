//
//  CrashModule.swift
//  TealiumCrash
//
//  Created by Jonathan Wong on 2/8/18.
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
    convenience init (config: TealiumConfig,
                      delegate: ModuleDelegate?,
                      diskStorage: TealiumDiskStorageProtocol?,
                      crashReporter: CrashReporterProtocol) {
        self.init(config: config, delegate: delegate, diskStorage: diskStorage) { _ in }
        self.crashReporter = crashReporter
    }

    /// Initializes the module
    ///
    /// - Parameters:
    ///   - config: `TealiumConfig` instance
    ///   - delegate: `TealiumModuleDelegate` instance
    ///   - diskStorage: `TealiumDiskStorageProtocol` instance
    ///   - completion: `ModuleCompletion` block to be called when init is finished
    required public init(config: TealiumConfig,
                         delegate: ModuleDelegate?,
                         diskStorage: TealiumDiskStorageProtocol?,
                         completion: ModuleCompletion) {
        self.delegate = delegate
        self.config = config
        self.diskStorage = diskStorage ?? TealiumDiskStorage(config: config, forModule: "crash", isCritical: false)
        self.crashReporter = CrashReporter()
        completion((.success(true), nil))
    }

}
