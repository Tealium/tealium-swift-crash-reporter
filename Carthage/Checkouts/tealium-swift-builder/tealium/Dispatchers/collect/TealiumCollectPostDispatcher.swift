//
//  TealiumCollectPostDispatcher.swift
//  tealium-swift
//
//  Created by Craig Rouse on 11/31/18.
//  Copyright © 2017 Tealium, Inc. All rights reserved.
//

import Foundation
#if collect
import TealiumCore
#endif

class TealiumCollectPostDispatcher: TealiumCollectProtocol {

    var urlSession: URLSessionProtocol?
    var urlSessionConfiguration: URLSessionConfiguration?
    static var defaultDispatchBaseURL = "https://collect.tealiumiq.com"
    static var singleEventPath = "/event/"
    static var bulkEventPath = "/bulk-event/"
    static var tealiumDomain = ".tealiumiq.com"

    var bulkEventDispatchURL: String?
    var singleEventDispatchURL: String?

    /// Initializes dispatcher￼.
    ///
    /// - Parameters:
    ///     - dispatchURL:`String` representation of the dispatch URL￼
    ///     - urlSession: `URLSession` to use for the dispatch (overridable for unit tests)￼
    ///     - completion: Completion handler to run when the dispatcher has finished initializing
    init(dispatchURL: String,
         urlSession: URLSessionProtocol = TealiumCollectPostDispatcher.getURLSession(),
         completion: ModuleCompletion? = nil) {
        self.urlSession = urlSession
        if TealiumCollectPostDispatcher.isValidUrl(url: dispatchURL) {
            // if using a custom endpoint, we recommend disabling batching, otherwise custom endpoint must handle batched events using Tealium's proprietary format
            // if using a CNAMEd domain, batching will work as normal.
            if let baseURL = TealiumCollectPostDispatcher.getDomainFromURLString(url: dispatchURL) {
                self.bulkEventDispatchURL = "https://\(baseURL)\(TealiumCollectPostDispatcher.bulkEventPath)"
                self.singleEventDispatchURL = "https://\(baseURL)\(TealiumCollectPostDispatcher.singleEventPath)"
            } else {
                // should never get here, as URL is already pre-validated
                setDefaultURLs()
            }
        } else {
            setDefaultURLs()
            completion?((.failure(TealiumCollectError.invalidDispatchURL), ["error": ""]))
            return
        }
        
        completion?((.success(true), nil))
    }

    /// Returns an ephemeral URLSession instance
    class func getURLSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        return URLSession(configuration: config)
    }

    /// Sets dispatch URLs to default values
    func setDefaultURLs() {
        // should never get here, as URL is already pre-validated
        self.bulkEventDispatchURL = "\(TealiumCollectPostDispatcher.defaultDispatchBaseURL)\(TealiumCollectPostDispatcher.bulkEventPath)"
        self.singleEventDispatchURL = "\(TealiumCollectPostDispatcher.defaultDispatchBaseURL)\(TealiumCollectPostDispatcher.singleEventPath)"
    }
    
    /// Gets the hostname from a url￼.
    ///
    /// - Parameter url: `String` representation of a URL
    /// - Returns: `String?` containing the hostname
    static func getDomainFromURLString(url: String) -> String? {
        guard let url = URL(string: url) else {
            return nil
        }

        return url.host
    }

    /// URL initializer does not actually validate web addresses successfully (it's too permissive), so this additional check is required￼.
    ///
    /// - Parameter url: `String` containing a URL to be validated
    /// - Returns: `Bool` `true` if URL is a valid web address
    static func isValidUrl(url: String) -> Bool {
        let urlRegexPattern = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        guard let validURLRegex = try? NSRegularExpression(pattern: urlRegexPattern, options: []) else {
            return false
        }
        return validURLRegex.rangeOfFirstMatch(in: url, options: [], range: NSRange(url.startIndex..., in: url)).location != NSNotFound
    }

    func dispatch(data: [String: Any],
                  completion: ModuleCompletion?) {
        dispatch(data: data, url: nil, completion: completion)
    }

    /// Dispatches data to an HTTP endpoint, then calls optional completion block when finished￼.
    ///
    /// - Parameters:
    ///     - data: `[String:Any]` of variables to be dispatched￼
    ///     - url: `String?` containing the dispatch URL to use. Defaults to single event dispatch url.￼
    ///     - completion: Optional completion block to be called when operation complete
    func dispatch(data: [String: Any],
                  url: String? = nil,
                  completion: ModuleCompletion?) {
        if let jsonString = data.toJSONString,
            let url = url ?? singleEventDispatchURL,
            let urlRequest = urlPOSTRequestWithJSONString(jsonString, dispatchURL: url) {
            sendURLRequest(urlRequest, completion)
        } else {
            completion?((.failure(TealiumCollectError.noDataToTrack), nil))
        }
    }

    /// Dispatches data to an HTTP endpoint, then calls optional completion block when finished.
    ///
    /// - Parameters:
    ///     - data: `[String:Any]` containing the nested data structure for a bulk dispatch
    ///     - completion: Optional completion block to be called when operation complete
    func dispatchBulk(data: [String: Any],
                      completion: ModuleCompletion?) {
        dispatch(data: data, url: bulkEventDispatchURL, completion: completion)
    }

    /// Sends a URLRequest, then calls the completion handler, passing success/failures back to the completion handler￼.
    ///
    /// - Parameters:
    ///     - request: `URLRequest` object￼
    ///     - completion: Optional completion block to handle success/failure
    func sendURLRequest(_ request: URLRequest,
                        _ completion: ModuleCompletion?) {
        if let urlSession = self.urlSession {
            let task = urlSession.tealiumDataTask(with: request) { _, response, error in
                if let error = error as? URLError {
                    completion?((.failure(error), nil))
                } else if let status = response as? HTTPURLResponse {
                    // error only indicates "no response from server. 400 responses are considered successful
                    if let errorHeader = status.allHeaderFields[TealiumCollectKey.errorHeaderKey] as? String {
                        completion?((.failure(TealiumCollectError.xErrorDetected), ["error": errorHeader]))
                    } else if status.statusCode != 200 {
                        completion?((.failure(TealiumCollectError.non200Response), nil))
                    } else {
                        completion?((.success(true), nil))
                    }
                }
            }
            task.resume()
        }
    }

    deinit {
        urlSessionConfiguration = nil
        urlSession?.finishTealiumTasksAndInvalidate()
        urlSession = nil
    }

}
