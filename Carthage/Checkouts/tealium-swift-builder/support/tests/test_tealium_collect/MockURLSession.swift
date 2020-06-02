//
//  MockURLSession.swift
//  tealium-swift
//
//  Created by Craig Rouse on 09/09/2019.
//  Copyright © 2019 Tealium, Inc. All rights reserved.
//

import Foundation
@testable import TealiumCollect
@testable import TealiumCore

class MockURLSession: URLSessionProtocol {
    func tealiumDataTask(with url: URL, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return DataTask(completionHandler: completionHandler, url: url)
    }

    func tealiumDataTask(with: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return DataTask(completionHandler: completionHandler, url: with.url!)
    }

    func finishTealiumTasksAndInvalidate() {
    }

}

class DataTask: URLSessionDataTaskProtocol {
    let completionHandler: DataTaskCompletion
    let url: URL
    init(completionHandler: @escaping DataTaskCompletion,
         url: URL) {
        self.completionHandler = completionHandler
        self.url = url
    }
    func resume() {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)
        completionHandler(nil, urlResponse, nil)
    }

}

class MockURLSessionError: URLSessionProtocol {
    func tealiumDataTask(with url: URL, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return DataTaskError(completionHandler: completionHandler, url: url)
    }

    func tealiumDataTask(with: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return DataTaskError(completionHandler: completionHandler, url: with.url!)
    }

    func finishTealiumTasksAndInvalidate() {
    }

}

class DataTaskError: URLSessionDataTaskProtocol {
    let completionHandler: DataTaskCompletion
    let url: URL
    init(completionHandler: @escaping DataTaskCompletion,
         url: URL) {
        self.completionHandler = completionHandler
        self.url = url
    }
    func resume() {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: [TealiumCollectKey.errorHeaderKey: "missing account/profile"])
        completionHandler(nil, urlResponse, nil)
    }

}

class MockURLSessionNon200: URLSessionProtocol {
    func tealiumDataTask(with url: URL, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return DataTaskErrorNon200(completionHandler: completionHandler, url: url)
    }

    // typealias DataTaskCompletion = (Data?, URLResponse?, Error?) -> Void
    func tealiumDataTask(with: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        //        let completion = DataTaskCompletion(nil, nil, nil)
        return DataTaskErrorNon200(completionHandler: completionHandler, url: with.url!)
    }

    func finishTealiumTasksAndInvalidate() {
    }

}

class DataTaskErrorNon200: URLSessionDataTaskProtocol {
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

class MockURLSessionURLError: URLSessionProtocol {
    func tealiumDataTask(with url: URL, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return DataTaskURLError(completionHandler: completionHandler, url: url)
    }

    func tealiumDataTask(with: URLRequest, completionHandler: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return DataTaskURLError(completionHandler: completionHandler, url: with.url!)
    }

    func finishTealiumTasksAndInvalidate() {
    }

}

class DataTaskURLError: URLSessionDataTaskProtocol {
    let completionHandler: DataTaskCompletion
    let url: URL
    init(completionHandler: @escaping DataTaskCompletion,
         url: URL) {
        self.completionHandler = completionHandler
        self.url = url
    }
    func resume() {
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: nil)
        completionHandler(nil, urlResponse, URLError(.appTransportSecurityRequiresSecureConnection))
    }

}
