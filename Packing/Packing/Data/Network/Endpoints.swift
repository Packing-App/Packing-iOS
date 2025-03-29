//
//  Endpoints.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum BaseURL {
    static let development = "http://localhost:5001"
    static let production = "https://port-0-node-express-m8mn7lwcb2d4bc3e.sel4.cloudtype.app"
}

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
//    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    
//    func decode<T: Decodable>(_ type: T.Type) throws -> T
//    func urlRequest(baseURL: URL) -> URLRequest
    func url(with baseURL: String) -> URL?
}

extension Endpoint {
    func url(with baseURL: String) -> URL? {
        return URL(string: baseURL + path)
    }
}

enum AuthEndpoint: Endpoint {
    
    // for email Login
    // for social Login
    case googleLogin
    case kakaoLogin
    case naverLogin
    case appleLogin(userId: String, email: String?, fullName: PersonNameComponents?)
    
    var path: String {
        switch self {
        case .googleLogin:
            return "/api/auth/google"
        case .kakaoLogin:
            return "/api/auth/kakao"
        case .naverLogin:
            return "/api/auth/naver"
        case .appleLogin:
            return "/api/auth/apple/verify"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .googleLogin, .kakaoLogin, .naverLogin: return .get
        case .appleLogin: return .post
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .appleLogin: return ["Content-Type": "application/json"]
        default: return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .appleLogin(userId: let userId, email: let email, fullName: let fullName):
            let payload: [String: Any] = [
                "userId": userId,
                "email": email ?? "",
                "fullName": [
                    "givenName": fullName?.givenName ?? "",
                    "familyName": fullName?.familyName ?? ""
                ],
            ]
            return try? JSONSerialization.data(withJSONObject: payload)
        default: return nil
        }
    }
        // MARK: - log out, delete user
}

