//
//  LifecycleModule.swift
//  TealiumSwift
//
//  Created by Christina S on 4/30/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation

#if TEST
#else
#if os(OSX)
#else
import UIKit
#endif
#endif

#if lifecycle
import TealiumCore
#endif

public class TealiumLifecycleModule: Collector {

    public let moduleId: String = "Lifecycle"
    weak var delegate: TealiumModuleDelegate?
    var enabledPrior = false
    var lifecycleData = [String: Any]()
    var lastLifecycleEvent: LifecycleType?
    var diskStorage: TealiumDiskStorageProtocol!
    public var config: TealiumConfig
    
    public var data: [String: Any]? {
        lifecycle?.asDictionary(type: nil, for: Date())
    }

    public required init(config: TealiumConfig,
                         delegate: TealiumModuleDelegate?,
                         diskStorage: TealiumDiskStorageProtocol?,
                         completion: ModuleCompletion) {
        self.delegate = delegate
        self.diskStorage = diskStorage ?? TealiumDiskStorage(config: config,
                                                             forModule: "lifecycle",
                                                             isCritical: true)
        self.delegate = delegate
        self.config = config
        if config.lifecycleAutoTrackingEnabled {
            Tealium.lifecycleListeners.addDelegate(delegate: self)
        }
        completion((.success(true), nil))
    }
    
    var lifecycle: TealiumLifecycle? {
        get {
            guard let storedData = diskStorage.retrieve(as: TealiumLifecycle.self) else {
                return TealiumLifecycle()
            }
            return storedData
        }
        set {
            if let newData = newValue {
                diskStorage.save(newData, completion: nil)
            }
        }
    }
    
    /// Determines if a lifecycle event should be triggered and requests a track.
    ///
    /// - Parameters:
    ///     - type: `TealiumLifecycleType`
    ///     - date: `Date` at which the event occurred
    public func process(type: LifecycleType,
        at date: Date, autotracked: Bool = false) {
        guard var lifecycle = self.lifecycle else {
            return
        }

        switch type {
        case .launch:
            if enabledPrior == true { return }
            enabledPrior = true
            lifecycleData += lifecycle.newLaunch(at: date,
                overrideSession: nil)
        case .sleep:
            lifecycleData += lifecycle.newSleep(at: date)
        case .wake:
            lifecycleData += lifecycle.newWake(at: date,
                overrideSession: nil)
        }
        self.lifecycle = lifecycle

        lifecycleData[LifecycleKey.autotracked] = autotracked
        requestTrack(data: lifecycleData)
    }
    
    /// Prevent manual spanning of repeated lifecycle calls to system.
    ///
    /// - Parameter type: `TealiumLifecycleType`
    /// - Returns: `Bool` `true` if process should be allowed to continue
    public func lifecycleAcceptable(type: LifecycleType) -> Bool {
        switch type {
        case .launch:
            if enabledPrior == true || lastLifecycleEvent != nil {
                return false
            }
        case .sleep:
            if lastLifecycleEvent != .wake && lastLifecycleEvent != .launch {
                return false
            }
        case .wake:
            if lastLifecycleEvent != .sleep {
                return false
            }
        }
        return true
    }
    
    /// Lifecycle event detected.
    /// - Parameters:
    ///   - type: `TealiumLifecycleType` launch, sleep, wake
    ///   - date: `Date` of lifecycle event
    public func lifecycleDetected(type: LifecycleType,
        at date: Date = Date()) {
        guard lifecycleAcceptable(type: type) else {
            return
        }
        lastLifecycleEvent = type
        self.process(type: type, at: date, autotracked: true)
    }
    
    /// Sends a track request to the module delegate.
    ///
    /// - Parameter data: `[String: Any]` containing the lifecycle data to track
    public func requestTrack(data: [String: Any]) {
        guard let title = data[LifecycleKey.type] as? String else {
            return
        }
        let trackData = Tealium.trackDataFor(title: title,
                                             optionalData: data)
        let track = TealiumTrackRequest(data: trackData,
                                        completion: nil)
        delegate?.requestTrack(track)
    }
}

extension TealiumLifecycleModule: TealiumLifecycleEvents {
    public func sleep() {
        lifecycleDetected(type: .sleep)
    }

    public func wake() {
        lifecycleDetected(type: .wake)
    }

    public func launch(at date: Date) {
        lifecycleDetected(type: .launch, at: date)
    }
}


