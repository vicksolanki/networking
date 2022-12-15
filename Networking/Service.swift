//
//  Service.swift
//  Networking
//
//  Created by Swipe Studio on 23/11/2022.
//

import Foundation

public enum ServiceMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

public protocol Service {
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: String]? { get }
    var method: ServiceMethod { get }
}

public extension Service {
    var urlRequest: URLRequest? {
        guard let url = self.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let authorizationHeader = ProcessInfo.processInfo.environment["AUTHORIZATION_HEADER"] {
            request.setValue("Bearer \(authorizationHeader)", forHTTPHeaderField: "Authorization")
        }
        
        if let userAgent = ProcessInfo.processInfo.environment["USER_AGENT"] {
            request.setValue("\(userAgent)", forHTTPHeaderField: "User-Agent")
        }
        
        return request
    }
    
    private var url: URL? {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = path
        
        if let parameters = parameters {
            urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return urlComponents?.url
    }
}
