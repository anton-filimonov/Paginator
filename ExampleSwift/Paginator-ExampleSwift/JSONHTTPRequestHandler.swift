//
//  JSONHTTPRequestHandler.swift
//  Paginator-ExampleSwift
//
//  Created by Anton Filimonov on 11/11/2017.
//  Copyright © 2017 Anton Filimonov. All rights reserved.
//

import Foundation
import AFPaginator

class JSONHTTPRequestHandler: DataRequestHandler {
    
    let requestTimeout: TimeInterval = 30
    let errorDomain = "JSONHTTPRequestHandlerErrorDomain"
    
    var processingDataTasks: [URLSessionDataTask] = []
    
    lazy var urlSession: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default)
    }()
    
    deinit {
        self.cancelAllRequests()
    }
    
    //MARK: DataRequestHandler
    
    func sendRequest(configuration requestConfiguration: Any,
                     completion completionHandler: @escaping (Any?, Error?) -> Void) {
        guard let requestConfiguration = requestConfiguration as? HTTPRequestConfiguration,
            let requestUrl = self.makeUrl(for: requestConfiguration)
            else { return }

        let request = URLRequest(url: requestUrl,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: self.requestTimeout)
        
        let dataTask = self.urlSession.dataTask(with: request) {
            [weak self] (data, _, error) in
            guard let `self` = self else { return }
            
            defer {
                self.removeCompletedTasks()
            }
            
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            
            guard let data = data else {
                completionHandler(nil, NSError(domain: self.errorDomain, code: 1000, userInfo: nil))
                return
            }
            
            if let result = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) {
                completionHandler(result, nil)
            } else {
                completionHandler(nil, NSError(domain: self.errorDomain, code: 1000, userInfo: nil))
            }
        }
        self.processingDataTasks.append(dataTask)
        dataTask.resume()
    }
    
    func cancelAllRequests() {
        for dataTask in self.processingDataTasks {
            dataTask.cancel()
        }
        self.processingDataTasks.removeAll()
    }
    
    //MARK: Helpers
    func makeUrl(for configuration: HTTPRequestConfiguration) -> URL? {
        var requestUrl = configuration.baseUrl
        if let path = configuration.requestPath {
            if let url = URL(string: path, relativeTo: configuration.baseUrl) {
                requestUrl = url
            } else {
                return nil
            }
        }
        
        var components = URLComponents(url: requestUrl, resolvingAgainstBaseURL: true)
        var query = components?.query ?? ""
        if query.count > 0 {
            query.append("&")
        }
        components?.query = configuration.parameters.reduce(query) {
            (lastResult, keyValuePair) -> String in
            let value: String
            if let stringValue = keyValuePair.value as? String {
                value = stringValue
            } else if let numberValue = keyValuePair.value as? NSNumber {
                value = numberValue.stringValue
            } else {
                return lastResult
            }
            
            return lastResult + "&" + keyValuePair.key + "=" + value
        }
        
        return components?.url
    }
    
    func removeCompletedTasks() {
        self.processingDataTasks = self.processingDataTasks.filter({ (task) -> Bool in
            return task.state != .completed
        })
    }
    
}
