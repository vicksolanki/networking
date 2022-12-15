//
//  MockService.swift
//  NetworkingTests
//
//  Created by Swipe Studio on 12/12/2022.
//

import Foundation
@testable import Networking

struct MockService: Service {
    
    let baseURL: String
    let path: String
    let parameters: [String: String]?
    let method: ServiceMethod 
    
    init(baseURL: String,
         path: String,
         parameters: [String: String]?,
         method: ServiceMethod) {
        self.baseURL = baseURL
        self.path = path
        self.parameters = parameters
        self.method = method
    }
}
