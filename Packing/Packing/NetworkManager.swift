//
//  NetworkManager.swift
//  Packing
//
//  Created by 이융의 on 3/27/25.
//

import Foundation
import AuthenticationServices

// MARK: - URL

enum BaseURL {
    static let development = ""
    static let production = "https://port-0-node-express-m8mn7lwcb2d4bc3e.sel4.cloudtype.app"
}

enum AuthRoute {
    case googleLogin
    case kakaoLogin
    case naverLogin
    case appleLogin
    
    var path: String {
        switch self {
        case .googleLogin: return "/api/auth/google"
        case .kakaoLogin: return "/api/auth/kakao"
        case .naverLogin: return "/api/auth/naver"
        case .appleLogin: return "/api/auth/apple"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL: String
    private let urlSession: URLSession
    
    private init() {
        #if DEBUG
        baseURL = BaseURL.development
        #else
        baseURL = BaseURL.production
        #endif
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        urlSession = URLSession(configuration: configuration)
    }
    
    func initiateOAuthLogin(route: AuthRoute, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: baseURL + route.path) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Optional: Add query parameters if needed
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        // Example: Add device-specific information
        components?.queryItems = [
            URLQueryItem(name: "device", value: UIDevice.current.identifierForVendor?.uuidString)
        ]
        
        guard let finalURL = components?.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        completion(.success(finalURL))
    }
    
    // New method for Apple login
    func sendAppleLoginCredentials(
        userId: String,
        email: String?,
        fullName: PersonNameComponents?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + "/api/auth/apple/verify") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = [
            "userId": userId,
            "email": email ?? "",
            "fullName": [
                "givenName": fullName?.givenName ?? "",
                "familyName": fullName?.familyName ?? ""
            ]
        ] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            let task = urlSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(NetworkError.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }
                
                completion(.success(()))
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    enum NetworkError: Error {
        case invalidURL
        case networkError(Error)
        case invalidResponse
    }
}
