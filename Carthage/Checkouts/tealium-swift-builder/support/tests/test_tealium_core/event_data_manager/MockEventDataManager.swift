//
//  MockEventData.swift
//  TealiumCore
//
//  Created by Christina S on 4/27/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation
@testable import TealiumCore

class MockEventDataManager: EventDataManagerProtocol {
    var sessionDataBacking = [String: Any]()
    var addSingleCount = 0
    var addMultiCount = 0
    var deleteSingleCount = 0
    var deleteMultiCount = 0
    var deleteAllCount = 0
    
    var allEventData: [String: Any] {
        get {
            ["all": "eventdata"]
        }
        set {
            self.add(data: newValue, expiration: .forever)
        }
    }

    var allSessionData: [String: Any] {
        ["all": "sessiondata"]
    }

    var minutesBetweenSessionIdentifier: TimeInterval = 1.0

    var secondsBetweenTrackEvents: TimeInterval = 1.0

    var sessionId: String? {
        get {
            "testsessionid"
        }
        set {
            self.add(data: ["sessionId": newValue!], expiration: .session)
        }
    }

    var sessionData: [String: Any] {
        get {
            ["session": "data"]
        }
        set {
            sessionDataBacking += newValue
        }
    }

    var sessionStarter: SessionStarterProtocol {
        MockTealiumSessionStarter()
    }

    var tagManagementIsEnabled: Bool = true

    func add(data: [String: Any], expiration: Expiration) {
        addMultiCount += 1
    }

    func add(key: String, value: Any, expiration: Expiration) {
        addSingleCount += 1
    }

    func addTrace(id: String) {
        
    }

    func delete(forKeys: [String]) {
        deleteMultiCount += 1
    }

    func delete(forKey key: String) {
        deleteSingleCount += 1
    }

    func deleteAll() {
        deleteAllCount += 1
    }

    func leaveTrace() {

    }

    func refreshSessionData() {

    }

    func sessionRefresh() {

    }

    func startNewSession(with sessionStarter: SessionStarterProtocol) {

    }

}
