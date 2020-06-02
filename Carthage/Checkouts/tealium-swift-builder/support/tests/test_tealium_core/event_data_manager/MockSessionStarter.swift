//
//  MockURLSessionSessionStarter.swift
//  TealiumCoreTests
//
//  Created by Christina S on 4/28/20.
//  Copyright © 2020 Tealium, Inc. All rights reserved.
//

import Foundation
@testable import TealiumCore

class MockTealiumSessionStarter: SessionStarterProtocol {

    var sessionURLCount = 0
    var sessionRequestCount = 0

    var sessionURL: String {
        sessionURLCount += 1
        return "http://www.tealium.com"
    }

    public init() { }

    func sessionRequest(_ completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) {
        sessionRequestCount += 1
    }

}

class MockURLSessionSessionStarter: URLSessionProtocol {

    func tealiumDataTask(with url: URL, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return SessionStarterDataTask(completionHandler: completionHandler, url: url)
    }

    func tealiumDataTask(with: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return SessionStarterDataTask(completionHandler: completionHandler, url: with.url!)
    }

    func finishTealiumTasksAndInvalidate() { }

}

class SessionStarterDataTask: URLSessionDataTaskProtocol {
    let completionHandler: DataTaskCompletion
    let url: URL

    init(completionHandler: @escaping DataTaskCompletion, url: URL) {
        self.completionHandler = completionHandler
        self.url = url
    }

    func resume() {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)
        completionHandler(nil, urlResponse, nil)
    }
}

class MockURLSessionSessionStarterInvalidResponse: URLSessionProtocol {

    func tealiumDataTask(with url: URL, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return SessionStarterDataTaskInvalidResponse(completionHandler: completionHandler, url: url)
    }

    func tealiumDataTask(with: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return SessionStarterDataTaskInvalidResponse(completionHandler: completionHandler, url: with.url!)
    }

    func finishTealiumTasksAndInvalidate() { }

}

class SessionStarterDataTaskInvalidResponse: URLSessionDataTaskProtocol {
    let completionHandler: DataTaskCompletion
    let url: URL

    init(completionHandler: @escaping DataTaskCompletion,
         url: URL) {
        self.completionHandler = completionHandler
        self.url = url
    }

    func resume() {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "1.1", headerFields: nil)
        completionHandler(nil, urlResponse, nil)
    }
}

class MockURLSessionSessionStarterRequestError: URLSessionProtocol {

    func tealiumDataTask(with url: URL, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return SessionStarterDataTaskError(completionHandler: completionHandler, url: url)
    }

    func tealiumDataTask(with: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return SessionStarterDataTaskError(completionHandler: completionHandler, url: with.url!)
    }

    func finishTealiumTasksAndInvalidate() { }

}

class SessionStarterDataTaskError: URLSessionDataTaskProtocol {
    let completionHandler: DataTaskCompletion
    let url: URL
    let error = MockSessionStarterRequestError.somethingWentWrong

    init(completionHandler: @escaping DataTaskCompletion,
         url: URL) {
        self.completionHandler = completionHandler
        self.url = url
    }

    func resume() {
        completionHandler(nil, nil, error)
    }
}

enum MockSessionStarterRequestError: Error, LocalizedError {
    case somethingWentWrong

    public var localizedDescription: String {
        switch self {
        case .somethingWentWrong:
            return NSLocalizedString("Something Went Wrong.", comment: "MockSessionStarterRequestError")
        }
    }
}
