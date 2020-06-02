//
//  TealiumVisitorServiceModule.swift
//  tealium-swift
//
//  Created by Christina Sund on 6/11/19.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//

import Foundation
#if visitorservice
import TealiumCore
#endif

public class TealiumVisitorServiceModule: Collector, DispatchListener {
    
    public let moduleId: String = "Visitor Service"
    public var config: TealiumConfig
    public var data: [String : Any]? = nil
    var diskStorage: TealiumDiskStorageProtocol!
    var firstEventSent = false
    var visitorId: String?
    var visitorServiceManager: TealiumVisitorServiceManagerProtocol?
    
    /// Provided for unit testing￼.
    ///
    /// - Parameter visitorServiceManager: Class instance conforming to `TealiumVisitorServiceManagerProtocol`
    convenience init (config: TealiumConfig,
                      delegate: TealiumModuleDelegate?,
                      diskStorage: TealiumDiskStorageProtocol?,
        visitorServiceManager: TealiumVisitorServiceManagerProtocol) {
        self.init(config: config, delegate: delegate, diskStorage: diskStorage) { result in }
        self.visitorServiceManager = visitorServiceManager
    }
    
    required public init(config: TealiumConfig,
                         delegate: TealiumModuleDelegate?,
                         diskStorage: TealiumDiskStorageProtocol?,
                         completion: ModuleCompletion) {
        self.config = config
        self.diskStorage = diskStorage ?? TealiumDiskStorage(config: config, forModule: "visitorservice", isCritical: false)
        self.visitorServiceManager = TealiumVisitorServiceManager(config: config,
        delegate: config.visitorServiceDelegate,
        diskStorage: self.diskStorage)
        completion((.success(true), nil))
    }

    func retrieveProfile(visitorId: String) {
        // wait before triggering refresh, to give event time to process
        TealiumQueues.backgroundConcurrentQueue.write(after: .now() + 2.1) {
            guard self.firstEventSent else {
                self.firstEventSent = true
                self.visitorServiceManager?.startProfileUpdates(visitorId: visitorId)
                return
            }
            self.visitorServiceManager?.requestVisitorProfile()
        }
    }
    
    public func willTrack(request: TealiumRequest) {
        switch request {
            case let request as TealiumTrackRequest:
                guard let visitorId = request.visitorId else {
                    return
                }
                retrieveProfile(visitorId: visitorId)
            case let request as TealiumBatchTrackRequest:
                guard let lastRequest = request.trackRequests.last,
                    let visitorId = lastRequest.visitorId else {
                    return
                }
                retrieveProfile(visitorId: visitorId)
        default:
            break
        }

    }
    
}
