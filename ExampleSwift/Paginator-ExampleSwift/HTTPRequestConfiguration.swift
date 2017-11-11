//
//  HTTPRequestConfiguration.swift
//  Paginator-ExampleSwift
//
//  Created by Anton Filimonov on 11/11/2017.
//  Copyright © 2017 Anton Filimonov. All rights reserved.
//

import Foundation

class HTTPRequestConfiguration {
    let baseUrl: URL
    let requestPath: String?
    let parameters: [String: Any]
    
    init(baseUrl: URL, requestPath: String?, parameters: [String: Any]) {
        self.baseUrl = baseUrl
        self.requestPath = requestPath
        self.parameters = parameters
    }
}
