//
//  CrashModule.swift
//  TealiumCrash
//
//  Created by Jonathan Wong on 2/8/18.
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

import Foundation
#if !COCOAPODS
import TealiumCore
#endif

public class TealiumCrashModule: Collector {   

    public let moduleId: String = "Crash"
    var crashReporter: CrashReporterProtocol?
    weak var delegate: TealiumModuleDelegate?
    var diskStorage: TealiumDiskStorageProtocol!
    public var config: TealiumConfig
    
    public var data: [String: Any]? {
        self.crashReporter?.getData()
    }

    /// Provided for unit testing￼.
    ///
    /// - Parameter crashReporter: Class instance conforming to `CrashReporterProtocol`
    convenience init (config: TealiumConfig,
                      delegate: TealiumModuleDelegate?,
                      diskStorage: TealiumDiskStorageProtocol?,
        crashReporter: CrashReporterProtocol) {
        self.init(config: config, delegate: delegate, diskStorage: diskStorage) { result in }
        self.crashReporter = crashReporter
    }
    
    required public init(config: TealiumConfig,
                         delegate: TealiumModuleDelegate?,
                         diskStorage: TealiumDiskStorageProtocol?,
                         completion: ModuleCompletion) {
        self.delegate = delegate
        self.config = config
        self.diskStorage = diskStorage ?? TealiumDiskStorage(config: config, forModule: "crash", isCritical: false)
        self.crashReporter = TealiumCrashReporter()
        completion((.success(true), nil))
    }

}
