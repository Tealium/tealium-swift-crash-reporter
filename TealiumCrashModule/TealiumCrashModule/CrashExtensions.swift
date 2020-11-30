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
