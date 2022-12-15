//
//  ServiceTests.swift
//  NetworkingTests
//
//  Created by Swipe Studio on 15/12/2022.
//

import XCTest
@testable import Networking

final class ServiceTests: XCTestCase {
    
    var sut: MockService!
    
    override func setUpWithError() throws {
        sut = MockService(baseURL: "https://mockservice.com",
                                  path: "/api/v2/search",
                                  parameters: ["testParameter": "expectedTestValue"],
                                  method: .get)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    
    func test_urlRequest_invalidBaseURL_returnsNil() {
        // given
        sut = MockService(baseURL: "invalidURL",
                          path: "//---",
                          parameters: nil,
                          method: .get)
        
        // then
        XCTAssertNil(sut.urlRequest)
    }
    
    func test_urlRequest_addsCorrectHTTPMethodToRequest() {
        // given
        let request = sut.urlRequest
        
        // then
        XCTAssertEqual(request?.httpMethod, ServiceMethod.get.rawValue)
    }
    
    func test_url_constructsURLWithCorrectParameters() {
        // given
        let urlString = sut.urlRequest?.url?.absoluteString
        
        // then
        XCTAssertEqual(urlString, "https://mockservice.com/api/v2/search?testParameter=expectedTestValue")
    }
}
