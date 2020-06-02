//
//  TealiumModuleDelegate.swift
//  TealiumCore
//
//  Created by Craig Rouse on 23/04/2020.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation

public protocol TealiumModuleDelegate: class {

    /// Called by a module send a new track request to the Dispatch Manager
    ///
    /// - Parameter track: TealiumTrackRequest
    func requestTrack(_ track: TealiumTrackRequest)
    
    func requestReleaseQueue(reason: String)
}
