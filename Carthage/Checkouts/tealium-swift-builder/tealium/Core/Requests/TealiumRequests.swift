//
//  TealiumRequests.swift
//  tealium-swift
//
//  Created by Jonathan Wong on 1/10/18.
//  Copyright © 2018 Tealium, Inc. All rights reserved.
//

// Requests are internal notification types used between the modules and
//  modules manager to enable, disable, load, save, delete, and process
//  track data. All request types most conform to the TealiumRequest protocol.
//  The module base class will respond by default to enable, disable, and track
//  but subclasses are expected to override these and/or implement handling of
//  any of the following additional requests or to a module's own custom request
//  type.

import Foundation

/// Request protocol
public protocol TealiumRequest {
    var typeId: String { get set }
    var completion: TealiumCompletion? { get set }

    static func instanceTypeId() -> String
}

// MARK: Update Config Request
public struct TealiumUpdateConfigRequest: TealiumRequest {
    public var typeId = TealiumUpdateConfigRequest.instanceTypeId()
    public var completion: TealiumCompletion?
    public let config: TealiumConfig

    public init(config: TealiumConfig) {
        self.config = config
    }

    public static func instanceTypeId() -> String {
        return "updateconfig"
    }
}

// MARK: Enqueue Request
/// Request to queue a track call
public struct TealiumEnqueueRequest: TealiumRequest {
    public var typeId = TealiumEnqueueRequest.instanceTypeId()
    public var completion: TealiumCompletion?
    public var data: [TealiumTrackRequest]
    var queueReason: String?

    public init(data: TealiumTrackRequest,
                queueReason: String? = nil,
                completion: TealiumCompletion?) {
        self.data = [data]
        self.queueReason = queueReason
        setQueueReason()
        self.completion = completion
    }

    public init(data: TealiumBatchTrackRequest,
                queueReason: String? = nil,
                completion: TealiumCompletion?) {
        self.data = data.trackRequests
        self.queueReason = queueReason
        setQueueReason()
        self.completion = completion
    }

    mutating func setQueueReason() {
        guard let queueReason = queueReason else {
            return
        }
        self.data = data.map {
            var data = $0.trackDictionary
            data[TealiumKey.queueReason] = queueReason
            return TealiumTrackRequest(data: data, completion: $0.completion)
        }
    }

    public static func instanceTypeId() -> String {
        return "enqueue"
    }
}

// MARK: Remote API Request
public struct TealiumRemoteAPIRequest: TealiumRequest {
    public var typeId = TealiumRemoteAPIRequest.instanceTypeId()
    public var completion: TealiumCompletion?
    public var trackRequest: TealiumTrackRequest

    public init(trackRequest: TealiumTrackRequest) {
        var trackRequestData = trackRequest.trackDictionary
        trackRequestData[TealiumKey.callType] = TealiumKey.remoteAPICallType
        self.trackRequest = TealiumTrackRequest(data: trackRequestData)
    }

    public static func instanceTypeId() -> String {
        return "remote_api"
    }

}

// MARK: Track Request
/// Request to deliver data.
public struct TealiumTrackRequest: TealiumRequest, Codable, Comparable {
    public static func < (lhs: TealiumTrackRequest, rhs: TealiumTrackRequest) -> Bool {
        guard let lhsTimestamp = lhs.trackDictionary[TealiumKey.timestampUnixMilliseconds] as? String,
            let rhsTimestamp = rhs.trackDictionary[TealiumKey.timestampUnixMilliseconds] as? String else {
                return false
        }
        guard let lhsTimestampInt = Int64(lhsTimestamp),
            let rhsTimestampInt = Int64(rhsTimestamp) else {
                return false
        }
        return lhsTimestampInt < rhsTimestampInt
    }

    public static func == (lhs: TealiumTrackRequest, rhs: TealiumTrackRequest) -> Bool {
        lhs.trackDictionary == rhs.trackDictionary
    }

    public var uuid: String {
        willSet {
            var data = self.trackDictionary
            data[TealiumKey.requestUUID] = newValue
            self.data = data.encodable
        }
    }
    public var typeId = TealiumTrackRequest.instanceTypeId()
    public var completion: TealiumCompletion?

    public var data: AnyEncodable

    public var trackDictionary: [String: Any] {
        if let data = data.value as? [String: Any] {
            return data
        }
        return ["": ""]
    }

    enum CodingKeys: String, CodingKey {
        case typeId
        case data
    }

    public init(data: [String: Any],
                completion: TealiumCompletion?) {
        self.uuid = data[TealiumKey.requestUUID] as? String ?? UUID().uuidString
        var data = data
        data[TealiumKey.requestUUID] = uuid
        self.data = data.encodable
        self.completion = completion
    }

    public init(data: [String: Any]) {
        self.init(data: data, completion: nil)
    }

    public static func instanceTypeId() -> String {
        return "track"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeId, forKey: .typeId)
        try container.encode(data, forKey: .data)
    }

    public var visitorId: String? {
        return self.trackDictionary[TealiumKey.visitorId] as? String
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let decoded = try values.decode(AnyDecodable.self, forKey: .data)
        var trackData = decoded.value as? [String: Any]
        if let uuid = trackData?[TealiumKey.requestUUID] as? String {
            self.uuid = uuid
        } else {
            self.uuid = UUID().uuidString
            trackData?[TealiumKey.requestUUID] = self.uuid
        }
        data = AnyEncodable(trackData)
        typeId = try values.decode(String.self, forKey: .typeId)
    }

    public mutating func deleteKey(_ key: String) {
        var dictionary = self.trackDictionary
        dictionary.removeValue(forKey: key)
        self.data = dictionary.encodable
    }

    public func event() -> String? {
        return self.trackDictionary[TealiumKey.event] as? String
    }

}

// MARK: Batch track request
public struct TealiumBatchTrackRequest: TealiumRequest, Codable {
    public var typeId = TealiumTrackRequest.instanceTypeId()
    public var uuid: String
    let sharedKeys = [TealiumKey.account,
                      TealiumKey.profile,
                      TealiumKey.dataSource,
                      TealiumKey.libraryName,
                      TealiumKey.libraryVersion,
                      TealiumKey.uuid,
                      TealiumKey.device,
                      TealiumKey.simpleModel,
                      TealiumKey.architectureLegacy,
                      TealiumKey.architecture,
                      TealiumKey.cpuType,
                      TealiumKey.cpuTypeLegacy,
                      TealiumKey.language,
                      TealiumKey.languageLegacy,
                      TealiumKey.resolution,
                      TealiumKey.platform,
                      TealiumKey.osName,
                      TealiumKey.fullModel,
                      TealiumKey.visitorId
    ]
    public var trackRequests: [TealiumTrackRequest]

    public var completion: TealiumCompletion?

    enum CodingKeys: String, CodingKey {
        case typeId
        case trackRequests
    }

    public static func instanceTypeId() -> String {
        return "batchtrack"
    }

    public init(trackRequests: [TealiumTrackRequest],
                completion: TealiumCompletion?) {
        self.trackRequests = trackRequests
        self.completion = completion
        self.uuid = UUID().uuidString
    }

    public init(from decoder: Decoder) throws {
        self.uuid = UUID().uuidString
        let values = try decoder.container(keyedBy: CodingKeys.self)

        trackRequests = try values.decode([TealiumTrackRequest].self, forKey: CodingKeys.trackRequests)
        typeId = try values.decode(String.self, forKey: .typeId)
    }

    /// - Returns: `[String: Any]?` containing the batched payload with shared keys extracted into `shared` object ``
    public func compressed() -> [String: Any]? {
        var events = [[String: Any]]()
        guard let firstRequest = trackRequests.first else {
            return nil
        }

        let shared = extractSharedKeys(from: firstRequest.trackDictionary)

        for request in trackRequests {
            let newRequest = request.trackDictionary.filter { !sharedKeys.contains($0.key) }
            events.append(newRequest)
        }

        return ["events": events, "shared": shared]
    }

    func extractSharedKeys(from dictionary: [String: Any]) -> [String: Any] {
        var newSharedDictionary = [String: Any]()

        sharedKeys.forEach { key in
            if dictionary[key] != nil {
                newSharedDictionary[key] = dictionary[key]
            }
        }

        return newSharedDictionary
    }

}
