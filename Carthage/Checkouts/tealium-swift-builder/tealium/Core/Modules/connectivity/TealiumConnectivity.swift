//
//  TealiumConnectivity.swift
//  tealium-swift
//
//  Created by Jason Koo on 6/26/17.
//  Copyright © 2017 Tealium, Inc. All rights reserved.
//

import Foundation

protocol TealiumConnectivityMonitorProtocol {
        init(config: TealiumConfig,
             completion: @escaping ((Result<Bool, Error>) -> Void))
    var config: TealiumConfig { get set }
    var currentConnnectionType: String? { get }
    var isConnected: Bool? { get }
    var isExpensive: Bool? { get }
    var isCellular: Bool? { get }
    var isWired: Bool? { get }
    func checkIsConnected(completion: @escaping ((Result<Bool, Error>) -> Void))
}

class TealiumConnectivity: Collector, TealiumConnectivityDelegate {

    var moduleId: String = "Connectivity"
    
    var data: [String : Any]? {
        if let connectionType = self.connectivityMonitor?.currentConnnectionType {
            return [TealiumConnectivityKey.connectionType: connectionType,
             TealiumConnectivityKey.connectionTypeLegacy: connectionType,
            ]
        } else {
            return [TealiumConnectivityKey.connectionType: TealiumConnectivityKey.connectionTypeUnknown,
                    TealiumConnectivityKey.connectionTypeLegacy: TealiumConnectivityKey.connectionTypeUnknown,
            ]
        }
    }
    
    var config: TealiumConfig {
        willSet {
            connectivityMonitor?.config = newValue
        }
    }
    
    // used to simulate connection status for unit tests
    var forceConnectionOverride: Bool?
    
    var connectivityMonitor: TealiumConnectivityMonitorProtocol?
    var connectivityDelegates = TealiumMulticastDelegate<TealiumConnectivityDelegate>()
    
    required init(config: TealiumConfig,
                  delegate: TealiumModuleDelegate?,
                  diskStorage: TealiumDiskStorageProtocol?,
                  completion: (ModuleResult) -> Void) {
            self.config = config

        if #available(iOS 12.0, tvOS 12.0, watchOS 5.0, OSX 10.14, *) {
            self.connectivityMonitor = TealiumNWPathMonitor(config: config) { result in
                switch result {
                case .success:
                    self.connectionRestored()
                case .failure:
                    self.connectionLost()
                }
            }
        } else {
            self.connectivityMonitor = LegacyConnectivityMonitor(config: config) { result in
                            switch result {
                            case .success:
                                self.connectionRestored()
                            case .failure:
                                self.connectionLost()
                            }
                        }
        }
    }
    
    func checkIsConnected(completion: @escaping ((Result<Bool, Error>) -> Void)) {
        guard forceConnectionOverride == nil || forceConnectionOverride == false else {
            completion(.success(true))
            return
        }
        self.connectivityMonitor?.checkIsConnected(completion: completion)
    }

    /// Method to add new classes implementing the TealiumConnectivityDelegate to subscribe to connectivity updates￼.
    ///
    /// - Parameter delegate: `TealiumConnectivityDelegate`
    func addConnectivityDelegate(delegate: TealiumConnectivityDelegate) {
        connectivityDelegates.add(delegate)
    }

    /// Removes all connectivity delegates.
    func removeAllConnectivityDelegates() {
        connectivityDelegates.removeAll()
    }

    // MARK: Delegate Methods

    /// Called when network connectivity is lost.
    func connectionLost() {
        connectivityDelegates.invoke {
            $0.connectionLost()
        }
    }

    /// Called when network connectivity is restored.
    func connectionRestored() {
        connectivityDelegates.invoke {
            $0.connectionRestored()
        }
    }
}
