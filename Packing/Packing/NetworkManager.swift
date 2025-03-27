//
//  NetworkManager.swift
//  Packing
//
//  Created by 이융의 on 3/27/25.
//

import Foundation
// MARK: - URL

enum BaseURL {
    static let development = ""
    static let production = "https://port-0-node-express-m8mn7lwcb2d4bc3e.sel4.cloudtype.app/"
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
    
    private init() {
        // Choose based on environment
        #if DEBUG
        baseURL = BaseURL.development
        #else
        baseURL = BaseURL.production
        #endif
    }
    
    func initiateOAuthLogin(route: AuthRoute, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: baseURL + route.path) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        completion(.success(url))
    }
    
    enum NetworkError: Error {
        case invalidURL
        case networkError(Error)
        case invalidResponse
    }
}
