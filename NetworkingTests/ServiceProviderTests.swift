//
//  ServiceProviderTests.swift
//  NetworkingTests
//
//  Created by Swipe Studio on 12/12/2022.
//

import XCTest
@testable import Networking

final class ServiceProviderTests: XCTestCase {
    
    private var sut: ServiceProvider<MockService>!
    private var mockService: MockService!
    
    override func setUpWithError() throws {
        mockService = MockService(baseURL: "https://mockservice.com",
                                  path: "/api/v2/search",
                                  parameters: nil,
                                  method: .get)
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        sut = ServiceProvider<MockService>(urlSession: urlSession)
    }
    
    override func tearDownWithError() throws {
        mockService = nil
        sut = nil
    }
    
    func test_load_invalidRequest_returnsInvalidURLError() {
        
        // given
        mockService = MockService(baseURL: "invalidURL",
                          path: "//---",
                          parameters: nil,
                          method: .get)
        let expectation = XCTestExpectation(description: "request should fail with invalid request error")
        
        // when
        sut.load(service: mockService) { result in
            switch result {
            case .failure(let error):
                guard case NetworkingError.invalidURL = error else {
                    XCTFail("incorrect error returned")
                    return
                }
            case .success:
                XCTFail("request should not succeed")
            }
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 1)
    }
    
    func test_loadDecodableObject_invalidRequest_returnsInvalidURLError() {
        
        // given
        mockService = MockService(baseURL: "invalidURL",
                          path: "//---",
                          parameters: nil,
                          method: .get)
        let expectation = XCTestExpectation(description: "request should fail with invalid request error")
        
        // when
        sut.load(service: mockService, decodeType: MockCodableObject.self) { result in
            switch result {
            case .failure(let error):
                guard case NetworkingError.invalidURL = error else {
                    XCTFail("incorrect error returned")
                    return
                }
            case .success:
                XCTFail("request should not succeed")
            }
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 1)
    }
    
    func test_load_nonHTTPResponse_returnsInvalidResponseError() {
        
        //given
        let expectedValue = "OK"
        let jsonString = """
                            {
                               "response": \(expectedValue),
                            }
                            """
        let data = jsonString.data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw MockError.invalidURL
            }
            let urlResponse = URLResponse(url: url,
                                          mimeType: "test",
                                          expectedContentLength: 200,
                                          textEncodingName: "testEncodingName")
            return (urlResponse, data)
        }
        
        let expectation = XCTestExpectation(description: "request should fail with invalid response error")
        
        //when
        sut.load(service: mockService) { result in
            switch result {
            case .failure(let error):
                guard case NetworkingError.noResponseFromServer = error else {
                    XCTFail("incorrect error returned")
                    return
                }
            case .success:
                XCTFail("request should not succeed")
            }
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 1)
    }
    
    func test_load_dataIsNotNil_returnsSuccessResponse() {
        
        //given
        let expectedValue = "OK"
        let jsonString = """
                            {
                               "response": \(expectedValue),
                            }
                            """
        let data = jsonString.data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw MockError.invalidURL
            }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let expectation = XCTestExpectation(description: "success response should be called with correct data")
        
        //when
        sut.load(service: mockService) { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(let error):
                XCTFail("Error was not expected: \(error)")
            }
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 1)
    }
    
    func test_load_dataIsNil_returnsNoDataError() {
        
        //given
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw MockError.invalidURL
            }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        
        let expectation = XCTestExpectation(description: "no data error should be returned")
        
        //when
        sut.load(service: mockService) { result in
            switch result {
            case .failure(let error):
                guard case NetworkingError.noDataReturned = error else {
                    XCTFail("incorrect error returned")
                    return
                }
            case .success:
                XCTFail("request should not succeed")
            }
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 1)
    }

    func test_load_unauthorizedRequest_returnsError() {

        //given
        let data = Data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw MockError.invalidURL
            }
            let response = HTTPURLResponse(url: url, statusCode: 403, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let expectation = XCTestExpectation(description: "data should be nil")

        //when
        sut.load(service: mockService) { result in
            guard case Result.failure = result else {
                XCTFail("request should fail with error")
                return
            }
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 1)
    }
    
    func test_loadDecodableObject_ServerRequests_returnsServerError() {

        //given
        let data = Data()
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw MockError.invalidURL
            }
            let response = HTTPURLResponse(url: url, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let expectation = XCTestExpectation(description: "server error should be returned")

        //when
        sut.load(service: mockService, decodeType: MockCodableObject.self) { result in
            switch result {
            case .failure(let error):
                guard case NetworkingError.serverError = error else {
                    XCTFail("incorrect error returned")
                    return
                }
            case .success:
                XCTFail("request should not succeed")
            }
            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 1)
    }
    
    func test_loadCodableObject_ValidObject_ShouldDecodeAndReturnObject() {
        
        //given
        let expectedStatus = "OK"
        let object = MockCodableObject(status: expectedStatus)
        guard let data = try? JSONEncoder().encode(object) else {
            XCTFail("Invalid codable object")
            return
        }
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw MockError.invalidURL
            }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let expectation = XCTestExpectation(description: "object should be decoded correctly")
        
        sut.load(service: mockService,
                 decodeType: MockCodableObject.self) { result in
            switch result {
            case .failure:
                XCTFail("request should not fail")
            case .success(let object):
                XCTAssertEqual(object.status, expectedStatus)
            }
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 1)
    }
    
    func test_loadCodableObject_InvalidObject_ThrowDecodingError() {
        //given
        let jsonString = """
                            {
                               "invalid": "not a mock codable object",
                            }
                            """
        let data = jsonString.data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url else {
                throw MockError.invalidURL
            }
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let expectation = XCTestExpectation(description: "object should be decoded correctly")
        
        sut.load(service: mockService,
                 decodeType: MockCodableObject.self) { result in
            switch result {
            case .failure(let error):
                guard case NetworkingError.errorDecodingResponse = error else {
                    XCTFail("incorrect error returned")
                    return
                }
            case .success:
                XCTFail("request should not succeed")
            }
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 1)
    }
}
