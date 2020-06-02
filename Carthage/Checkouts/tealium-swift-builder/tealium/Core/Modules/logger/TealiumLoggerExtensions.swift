//
//  TealiumLoggerExtensions.swift
//  TealiumLogger
//
//  Created by Craig Rouse on 23/09/2019.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//

import Foundation

public extension Tealium {

    func logger() -> TealiumLoggerProtocol? {
        zz_internal_modulesManager?.logger
    }
}
