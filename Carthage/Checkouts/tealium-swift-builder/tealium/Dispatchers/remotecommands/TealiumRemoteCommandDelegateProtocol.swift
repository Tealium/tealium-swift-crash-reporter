//
//  TealiumRemoteCommandDelegateProtocol.swift
//  tealium-swift
//
//  Created by Craig Rouse on 11/03/2019.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//
#if os(iOS)
import Foundation
#if remotecommands
import TealiumCore
#endif

protocol TealiumRemoteCommandDelegate: class {

    /// Triggers the completion block registered for a specific remote command
    ///
    /// - Parameters:
    ///     - command: `TealiumRemoteCommandd` to be executed
    ///     - response: `TealiumRemoteCommandResponse` object passed back from TiQ. If the command needs to explictly handle the response (e.g. data needs passing back to webview),
    ///      it must set the "hasCustomCompletionHandler" flag, otherwise the completion notification will be sent automatically
    func tealiumRemoteCommandRequestsExecution(_ command: TealiumRemoteCommand,
                                               response: TealiumRemoteCommandResponse)
}
#endif
