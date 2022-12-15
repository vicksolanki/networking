//
//  NetworkingError.swift
//  Networking
//
//  Created by Swipe Studio on 12/12/2022.
//

import Foundation

public enum NetworkingError: Error {
    case noResponseFromServer
    case invalidURL
    case serverError
    case errorDecodingResponse
    case noDataReturned
}
