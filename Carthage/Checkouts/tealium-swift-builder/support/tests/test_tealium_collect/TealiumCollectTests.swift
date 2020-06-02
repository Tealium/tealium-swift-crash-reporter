//
//  TealiumCollectTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 9/6/16.
//  Copyright © 2016 Tealium, Inc. All rights reserved.
//

@testable import TealiumCollect
@testable import TealiumCore
import XCTest

class TealiumCollectTests: XCTestCase {

    let testJSONString = """
                            {\n  \"tealium_account\" : \"hello\",\n  \"tealium_environment\" : \"dev\",\n  \"tealium_profile\" : \"tester\"\n}
                            """
    let testDictionary = ["tealium_account": "hello",
                          "tealium_environment": "dev",
                          "tealium_profile": "tester"
    ]

    var mockURLSession: URLSessionProtocol!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func validTestDataDictionary() -> [String: Any] {
        return [
            TealiumKey.account: "account",
            TealiumKey.profile: "profile" ,
            TealiumKey.environment: "environment" ,
            TealiumKey.event: "test" ,
            TealiumKey.libraryName: TealiumValue.libraryName ,
            TealiumKey.libraryVersion: TealiumValue.libraryVersion ,
            TealiumKey.sessionId: "someSessionId" ,
            TealiumKey.visitorId: "someVisitorId" ,
            TealiumKey.random: "someRandomNumber"
        ]
    }

    func testInitWithBaseURLString() {
        // invalid url
        let string = "tealium"

        _ = TealiumCollectPostDispatcher(dispatchURL: string) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.invalidDispatchURL)
            case .success:
                XCTFail("Unexpected Success")
            }
        }
    }

    func testInitWithBaseURLStringDefaultURLs() {
        // invalid url
        let string = "tealium"

        let dispatcher = TealiumCollectPostDispatcher(dispatchURL: string)

        guard let bulkURL = dispatcher.bulkEventDispatchURL else {
            XCTFail("Missing bulk url")
            return
        }

        guard let url = dispatcher.singleEventDispatchURL else {
            XCTFail("Missing single event url")
            return
        }

        XCTAssertEqual(bulkURL, "\(TealiumCollectPostDispatcher.defaultDispatchBaseURL)\(TealiumCollectPostDispatcher.bulkEventPath)")
        XCTAssertEqual(url, "\(TealiumCollectPostDispatcher.defaultDispatchBaseURL)\(TealiumCollectPostDispatcher.singleEventPath)")
    }

    func testGetDomainFromURLStringInvalidURL() {
        XCTAssertNil(TealiumCollectPostDispatcher.getDomainFromURLString(url: "hello"))
    }

    func testGetDomainFromURLString() {
        XCTAssertEqual("tealium.com", TealiumCollectPostDispatcher.getDomainFromURLString(url: "https://tealium.com")!)
    }

    func testInitWithInvalidBaseURLString() {
        // invalid url
        let string = "https://tealium/"
        _ = TealiumCollectPostDispatcher(dispatchURL: string) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.invalidDispatchURL)
            case .success:
                XCTFail("Unexpected Success")
            }
        }
    }

    func testGetURLSessionReturnsEphemeralSession() {
        let session = TealiumCollectPostDispatcher.getURLSession()

        XCTAssertNotEqual(session.configuration.httpCookieStorage!.debugDescription, URLSessionConfiguration.default.httpCookieStorage!.debugDescription)
        XCTAssertEqual(session.configuration.httpCookieStorage!.debugDescription, URLSessionConfiguration.ephemeral.httpCookieStorage!.debugDescription)
    }

    func testValidURL() {
        let validURL = "https://collect.tealiumiq.com/event/"
        XCTAssertTrue(TealiumCollectPostDispatcher.isValidUrl(url: validURL), "isValidURL returned unexpected failure")
        let invalidURL = "invalidURL"
        XCTAssertFalse(TealiumCollectPostDispatcher.isValidUrl(url: invalidURL), "isValidURL returned unexpected success")
    }

    func testSendURLRequest() {
        mockURLSession = MockURLSession()
        guard let request = urlPOSTRequestWithJSONString(testJSONString, dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL) else {
            XCTFail("Could not create post request")
            return
        }
        let dispatcher = TealiumCollectPostDispatcher(dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL, urlSession: mockURLSession)
        dispatcher.sendURLRequest(request) { result in
            switch result.0 {
            case .failure:
                XCTFail("Unexpected failure")
            case .success(let success):
                XCTAssertTrue(success)
                XCTAssertNil(result.1)
            }
        }
    }

    func testSendURLRequestFailingURL() {
        mockURLSession = MockURLSessionError()
        guard let request = urlPOSTRequestWithJSONString(testJSONString, dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL) else {
            XCTFail("Could not create post request")
            return
        }
        let dispatcher = TealiumCollectPostDispatcher(dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL, urlSession: mockURLSession)
        dispatcher.sendURLRequest(request) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.xErrorDetected)
                XCTAssertNotNil(result.1)
            case .success:
                XCTFail("Unexpected success")
            }
        }
    }

    func testSendURLRequestNon200() {
        mockURLSession = MockURLSessionNon200()
        guard let request = urlPOSTRequestWithJSONString(testJSONString, dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL) else {
            XCTFail("Could not create post request")
            return
        }
        let dispatcher = TealiumCollectPostDispatcher(dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL, urlSession: mockURLSession)
        dispatcher.sendURLRequest(request) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.non200Response)
            case .success:
                XCTFail("Unexpected success")
            }
        }
    }

    func testSendURLRequestURLError() {
        mockURLSession = MockURLSessionURLError()
        guard let request = urlPOSTRequestWithJSONString(testJSONString, dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL) else {
            XCTFail("Could not create post request")
            return
        }
        let dispatcher = TealiumCollectPostDispatcher(dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL, urlSession: mockURLSession)
        dispatcher.sendURLRequest(request) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual((error as! URLError).code, URLError.Code.appTransportSecurityRequiresSecureConnection)
            case .success:
                XCTFail("Unexpected success")
            }
        }
    }

    func testDispatch() {
        mockURLSession = MockURLSession()
        let dispatcher = TealiumCollectPostDispatcher(dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL, urlSession: mockURLSession)
        dispatcher.dispatch(data: self.testDictionary) { result in
            switch result.0 {
            case .failure:
                XCTFail("Unexpected failure")
            case .success(let success):
                XCTAssertTrue(success)
                XCTAssertNil(result.1)
            }
        }
    }

    func testDispatchWithError() {
        mockURLSession = MockURLSessionError()
        let dispatcher = TealiumCollectPostDispatcher(dispatchURL: TealiumCollectPostDispatcher.defaultDispatchBaseURL, urlSession: mockURLSession)
        dispatcher.dispatch(data: self.testDictionary) { result in
            switch result.0 {
            case .failure(let error):
                XCTAssertEqual(error as! TealiumCollectError, TealiumCollectError.xErrorDetected)
                XCTAssertNotNil(result.1)
            case .success:
                XCTFail("Unexpected success")
            }
        }
    }

}
