//
//  DispatcherProtocol.swift
//  TealiumCore
//
//  Created by Craig Rouse on 23/04/2020.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation

public protocol Dispatcher: TealiumModule {
    var isReady: Bool { get }
    init(config: TealiumConfig,
         delegate: TealiumModuleDelegate,
         completion: ModuleCompletion?)

    func dynamicTrack(_ request: TealiumRequest,
                      completion: ModuleCompletion?)
}
