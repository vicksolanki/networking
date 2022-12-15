//
//  ServiceProvider.swift
//  Networking
//
//  Created by Swipe Studio on 23/11/2022.
//

import Foundation

public class ServiceProvider<T: Service> {
    private let urlSession: URLSession
    
    public init(urlSession: URLSession = .shared){
        self.urlSession = urlSession
    }
    
    public func load(service: T,
                     completion: @escaping (Result<Data, NetworkingError>) -> Void) {
        guard let urlRequest = service.urlRequest else {
            completion(.failure(.invalidURL))
            return
        }
        call(urlRequest, completion: completion)
    }
    
    public func load<U>(service: T,
                        decodeType: U.Type,
                        completion: @escaping (Result<U, NetworkingError>) -> Void) where U: Decodable {
        guard let urlRequest = service.urlRequest else {
            completion(.failure(.invalidURL))
            return
        }
        
        call(urlRequest) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(decodeType, from: data)
                    completion(.success(response))
                }
                catch {
                    completion(.failure(.errorDecodingResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension ServiceProvider {
    private func call(_ request: URLRequest,
                      deliverQueue: DispatchQueue = DispatchQueue.main,
                      completion: @escaping (Result<Data, NetworkingError>) -> Void) {
        
        urlSession.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                deliverQueue.async {
                    completion(.failure(.noResponseFromServer))
                }
                return
            }
            
            guard httpResponse.statusCode == 200,
                  error == nil else {
                print("API Error \(String(describing: error))")
                deliverQueue.async {
                    completion(.failure(.serverError))
                }
                return
            }
            
            guard let data = data,
            data.isEmpty == false else {
                deliverQueue.async {
                    completion(.failure(.noDataReturned))
                }
                
                return
            }
            
            print("response: \(String(describing: data.prettyPrintedJSONString))")
            
            deliverQueue.async {
                completion(.success(data))
            }
            
        }
        .resume()
    }
}
