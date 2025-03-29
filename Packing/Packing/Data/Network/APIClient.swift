//
//  APIClient.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import UIKit    // for device id
import RxSwift

enum NetworkError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
}

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    
    private init() {
        #if DEBUG
        baseURL = BaseURL.development
        #else
        baseURL = BaseURL.production
        #endif
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        session = URLSession(configuration: configuration)
    }
    
    // Endpoint( 프로토콜을 준수하는 값이 파라미터로 들어옴.
    // for apple login
    func request<T: Decodable>(endpoint: Endpoint) -> Observable<T> {
        // 나중에 생기는 데이터
        return Observable.create { observer in
            
            // 1. url (baseURL + path)
            guard let url = endpoint.url(with: self.baseURL) else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            
            // 2. httpMethod(put, post, get, delete)
            request.httpMethod = endpoint.method.rawValue
            
            // 3. header (contentType: application/json)
            if let headers = endpoint.headers {
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            // 4. body (data)
            if let body = endpoint.body {
                request.httpBody = body
            }
            
            // 5. task
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(NetworkError.networkError(error))
                    // return
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    observer.onError(NetworkError.invalidResponse)
                    return
                }
                
                if let data = data {
                    do {
                        let decodedObject = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(decodedObject)
                        observer.onCompleted()
                    } catch let error {
                        observer.onError(NetworkError.decodingError(error))
                    }
                }
            }
            
            task.resume()
            
            // Disposable 생성 시 task cancel
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    
    // for social login (google, kakao, naver)
    // callback url
    func initiateOAuthURL(route: AuthRoute) -> Observable<URL> {
        return Observable.create { observer in
            guard let url = URL(string: self.baseURL + route.path) else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            // Add query parameters
            // 이 코드가 꼭 필요한건지(확인해야함)
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            // Add device-specific information
            components?.queryItems = [
                URLQueryItem(name: "device", value: UIDevice.current.identifierForVendor?.uuidString)
            ]
            
            guard let finalURL = components?.url else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            // Rxswift - observer onNext
            observer.onNext(finalURL)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}

