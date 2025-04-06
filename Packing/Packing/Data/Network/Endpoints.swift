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

protocol Endpoints {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var baseURL: String { get }
    func url() -> URL?
}

extension Endpoints {
    var baseURL: String {
        return "https://port-0-node-express-m8mn7lwcb2d4bc3e.sel4.cloudtype.app/api"
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    func url() -> URL? {
        return URL(string: baseURL + path)
    }
}

enum APIEndpoint: Endpoints {
    
    // MARK: - AUTH ENDPOINTS
    // 이메일 회원가입
    case register(name: String, email: String, password: String)
    
    // 이메일 로그인
    case login(email: String, password: String)
    
    // 이메일 인증
    case verifyEmail(email: String, code: String)
    case resendVerificationCode(email: String)
    
    // 비밀번호 찾기
    case forgotPassword(email: String)
    case verifyResetCode(email: String, code: String)
    case resetPassword(email: String, code: String, password: String)
    
    // 비밀번호 재설정(로그인 상태)
    case changePassword(currentPassword: String, newPassword: String)
    
    // refresh Token 으로 access token 재발급 (자동 로그인)
    case refreshToken(refreshToken: String)
    
    // 로그아웃(to make refresh Token to null)
    case logout
    
    // 계정삭제 (이메일, 소셜로그인(revoke social account))
    case deleteAccount
    
    // Sign in with apple
    case appleVerify(userId: String, email: String?, fullName: PersonNameComponents?)
    
    // Sign in with google, kakao, naver (to be opened in AuthenticationServices)
    case googleLogin
    case kakaoLogin
    case naverLogin
    
    // MARK: - USER PROFILE ENDPOINTS
    
    case getMyProfile
    case updateProfile(name: String, intro: String)
    case updateProfileImage(imageData: Data)
    
    // MARK: - PATH
    var path: String {
        switch self {
        // Auth
        case .register:
            return "/auth/register"
        case .login:
            return "/auth/login"
        case .verifyEmail:
            return "/auth/verify-email"
        case .resendVerificationCode:
            return "/auth/resend-verification"
        case .forgotPassword:
            return "/auth/forgot-password"
        case .verifyResetCode:
            return "/auth/verify-reset-code"
        case .resetPassword:
            return "/auth/reset-password"
        case .changePassword:
            return "/auth/change-password"
        case .refreshToken:
            return "/auth/refresh-token"
        case .logout:
            return "/auth/logout"
        case .deleteAccount:
            return "/auth/delete-account"
            
        // Social Login
        case .appleVerify:
            return "/auth/apple/verify"
        case .googleLogin:
            return "/auth/google"
        case .kakaoLogin:
            return "/auth/kakao"
        case .naverLogin:
            return "/auth/naver"
            
        // user profile
        case .getMyProfile, .updateProfile:
            return "/users/me"
        case .updateProfileImage:
            return "/users/me/profile-image"
        }
    }
    
    // MARK: - METHODS
    
    var method: HTTPMethod {
        switch self {
        case .register, .login, .verifyEmail, .resendVerificationCode, .forgotPassword, .verifyResetCode, .resetPassword, .changePassword, .refreshToken, .appleVerify:
            return .post
        case .logout:
            return .post
        case .deleteAccount:
            return .delete
        case .getMyProfile:
            return .get
        case .updateProfile:
            return .put
        case .updateProfileImage:
            return .put
        case .googleLogin, .kakaoLogin, .naverLogin:
            return .get
        }
    }
    
    // MARK: - PARAMETERS
    
    var parameters: [String : Any]? {
        switch self {
        case .register(let name, let email, let password):
            return ["name": name, "email": email, "password": password]
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .verifyEmail(let email, let code):
            return ["email": email, "code": code]
        case .resendVerificationCode(let email):
            return ["email": email]
        case .forgotPassword(let email):
            return ["email": email]
        case .verifyResetCode(let email, let code):
            return ["email": email, "code": code]
        case .resetPassword(let email, let password, let code):
            return ["email": email, "password": password, "code": code]
        case .changePassword(let currentPassword, let newPassword):
            return ["currentPassword": currentPassword, "newPassword": newPassword]
        case .refreshToken(let refreshToken):
            return ["refreshToken": refreshToken]
        
            // social Login
        case .appleVerify(let userId, let email, let fullName):
            var params: [String: Any] = ["userId": userId]
            
            if let email = email, !email.isEmpty {
                params["email"] = email
            }
            
            if let fullName = fullName {
                var nameParams: [String: String?] = [:]
                if let givenName = fullName.givenName {
                    nameParams["givenName"] = givenName
                }
                if let familyName = fullName.familyName {
                    nameParams["familyName"] = familyName
                }
                if !nameParams.isEmpty {
                    params["fullName"] = nameParams
                }
            }
            
            return params
        case .updateProfile(let name, let intro):
            return ["name": name, "intro": intro]
        default: return nil
        }
    }
}
