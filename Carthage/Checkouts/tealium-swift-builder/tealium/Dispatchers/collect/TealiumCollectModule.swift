//
//  CollectModule.swift
//  TealiumCore
//
//  Created by Craig Rouse on 24/04/2020.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation
import TealiumCore

/// Dispatch Service Module for sending track data to the Tealium Collect or custom endpoint.
public class TealiumCollectModule: Dispatcher {    
    
    public let moduleId: String = "Collect"
    var collect: TealiumCollectProtocol?
    public var isReady = false
    weak var delegate: TealiumModuleDelegate?
    public var config: TealiumConfig
    
    public required init(config: TealiumConfig,
                         delegate: TealiumModuleDelegate,
                         completion: ModuleCompletion?) {
        
        self.config = config
        self.delegate = delegate
        updateCollectDispatcher(config: config, completion: nil)
        completion?((.success(true), nil))
    }

    func updateCollectDispatcher(config: TealiumConfig,
                                 completion: ModuleCompletion?) {
        let urlString = config.optionalData[TealiumCollectKey.overrideCollectUrl] as? String ?? TealiumCollectPostDispatcher.defaultDispatchBaseURL
        collect = TealiumCollectPostDispatcher(dispatchURL: urlString, completion: completion)
    }

    /// Detects track type and dispatches appropriately, adding mandatory data (account and profile) to the track if missing.￼
    ///
    /// - Parameter track: `TealiumRequest`, which is expected to be either a `TealiumTrackRequest` or a `TealiumBatchTrackRequest`
    public func dynamicTrack(_ request: TealiumRequest,
                             completion: ModuleCompletion?) {
        guard collect != nil else {
            completion?((.failure(TealiumCollectError.collectNotInitialized), nil))
            return
        }

        switch request {
        case let request as TealiumTrackRequest:
            guard request.trackDictionary[TealiumKey.event] as? String != TealiumKey.updateConsentCookieEventName else {
                completion?((.failure(TealiumCollectError.trackNotApplicableForCollectModule), nil))
                return
            }
            self.track(prepareForDispatch(request), completion: completion)
        case let request as TealiumBatchTrackRequest:
            var requests = request.trackRequests
            requests = requests.filter {
                $0.trackDictionary[TealiumKey.event] as? String != TealiumKey.updateConsentCookieEventName
            }.map {
                prepareForDispatch($0)
            }
            guard !requests.isEmpty else {
                completion?((.failure(TealiumCollectError.trackNotApplicableForCollectModule), nil))
                return
            }
            let newRequest = TealiumBatchTrackRequest(trackRequests: requests, completion: request.completion)
            self.batchTrack(newRequest, completion: completion)
        default:
            completion?((.failure(TealiumCollectError.trackNotApplicableForCollectModule), nil))
            return
        }
    }

    /// Adds required account information to the dispatch if missing￼.
    ///
    /// - Parameter request: `TealiumTrackRequest` to be insepcted/modified
    /// - Returns: `TealiumTrackRequest`
    func prepareForDispatch(_ request: TealiumTrackRequest) -> TealiumTrackRequest {
        var newTrack = request.trackDictionary
        if newTrack[TealiumKey.account] == nil,
            newTrack[TealiumKey.profile] == nil {
            newTrack[TealiumKey.account] = config.account
            newTrack[TealiumKey.profile] = config.profile
        }

        if let profileOverride = config.collectOverrideProfile {
            newTrack[TealiumKey.profile] = profileOverride
        }

        newTrack[TealiumKey.dispatchService] = TealiumCollectKey.moduleName
        return TealiumTrackRequest(data: newTrack, completion: request.completion)
    }

    /// Adds relevant info to the track request, then passes the request to a dipatcher for processing￼.
    ///
    /// - Parameter track: `TealiumTrackRequest` to be dispatched
    func track(_ track: TealiumTrackRequest,
               completion: ModuleCompletion?) {
        guard let collect = collect else {
            completion?((.failure(TealiumCollectError.collectNotInitialized), nil))
            return
        }

        // Send the current track call
        let data = track.trackDictionary

        collect.dispatch(data: data, completion: completion)
    }

    /// Adds relevant info to the track request, then passes the request to a dipatcher for processing￼.
    ///
    /// - Parameter track: `TealiumBatchTrackRequest` to be dispatched
    func batchTrack(_ request: TealiumBatchTrackRequest,
                    completion: ModuleCompletion?) {
        guard let collect = collect else {
            completion?((.failure(TealiumCollectError.collectNotInitialized), nil))
            return
        }

        guard let compressed = request.compressed() else {
            completion?((.failure(TealiumCollectError.invalidBatchRequest), nil))
            return
        }

        collect.dispatchBulk(data: compressed, completion: completion)
    }

}
