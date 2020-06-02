//
//  TealiumVisitorProfileExtensions.swift
//  tealium-swift
//
//  Created by Christina Sund on 5/16/19.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//

import Foundation
#if visitorservice
import TealiumCore
#endif

extension Int64 {

    /// Converts minutes to milliseconds
    var milliseconds: Int64 {
        return self * 60 * 1000
    }
}

public extension Tealium {

    /// - Returns: `VisitorServiceManager` instance
    func visitorService() -> TealiumVisitorServiceManager? {
        (zz_internal_modulesManager?.modules.first {
            type(of: $0) == TealiumVisitorServiceModule.self
        } as? TealiumVisitorServiceModule)?.visitorServiceManager as? TealiumVisitorServiceManager
    }
}

public extension TealiumConfig {

    /// Sets the default refresh interval for visitor profile retrieval. Default is 5 minutes
    /// Set to `0` if the profile should always be fetched following a track request.
    /// - Parameter interval: `Int64` containing the refresh interval
    @available(*, deprecated, message: "Please switch to config.visitorServiceRefreshInterval")
    func setVisitorServiceRefresh(interval: Int64) {
        visitorServiceRefreshInterval = interval
    }

    /// Sets the default refresh interval for visitor profile retrieval. Default is 5 minutes
    /// Set to `0` if the profile should always be fetched following a track request.
    var visitorServiceRefreshInterval: Int64? {
        get {
            optionalData[TealiumVisitorServiceConstants.refreshInterval] as? Int64
        }

        set {
            optionalData[TealiumVisitorServiceConstants.refreshInterval] = newValue
        }
    }

    /// Visitor service delegates to be notified of any changes to the visitor profile.
    /// Note: if no delegates are registered, no requests will be made to fetch the visitor profile from the server.
    var visitorServiceDelegate: TealiumVisitorServiceDelegate? {
        get {
            optionalData[TealiumVisitorServiceConstants.visitorServiceDelegate] as? TealiumVisitorServiceDelegate
        }

        set {
            optionalData[TealiumVisitorServiceConstants.visitorServiceDelegate] = newValue
        }
    }

    /// Overrides the default visitor service URL (visitor-service.tealiumiq.com).
    /// Format: https://overridden-subdomain.yourdomain.com/
    /// - Parameter url: `String` representing a valid URL. If an invalid URL is passed, the default is used instead.
    @available(*, deprecated, message: "Please switch to config.visitorServiceOverrideURL")
    func setVisitorServiceOverrideURL(_ url: String) {
        visitorServiceOverrideURL = url
    }

    /// - Returns: `String?` containing the URL from which to retieve the visitor profile.
    @available(*, deprecated, message: "Please switch to config.visitorServiceOverrideURL")
    func getVisitorServiceOverrideURL() -> String? {
        visitorServiceOverrideURL
    }

    /// Overrides the default visitor service URL (visitor-service.tealiumiq.com).  If an invalid URL is passed, the default is used instead.
    /// Format: https://overridden-subdomain.yourdomain.com/
    var visitorServiceOverrideURL: String? {
        get {
            optionalData[TealiumVisitorServiceConstants.visitorServiceOverrideURL] as? String
        }

        set {
            optionalData[TealiumVisitorServiceConstants.visitorServiceOverrideURL] = newValue
        }
    }

    /// Sets a specific overridden profile from which to fetch the visitor profile.
    /// - Parameter profile: `String` representing the profile name from which to retrieve the visitor profile.
    @available(*, deprecated, message: "Please switch to config.visitorServiceOverrideProfile")
    func setVisitorServiceOverrideProfile(_ profile: String) {
        visitorServiceOverrideProfile = profile
    }

    /// - Returns: `String?` containing the profile name from which to retrieve the visitor profile
    @available(*, deprecated, message: "Please switch to config.visitorServiceOverrideProfile")
    func getVisitorServiceOverrideProfile() -> String? {
        visitorServiceOverrideProfile
    }

    /// Sets a specific overridden profile from which to fetch the visitor profile.
    var visitorServiceOverrideProfile: String? {
        get {
            optionalData[TealiumVisitorServiceConstants.visitorServiceOverrideProfile] as? String
        }

        set {
            optionalData[TealiumVisitorServiceConstants.visitorServiceOverrideProfile] = newValue
        }
    }
}
