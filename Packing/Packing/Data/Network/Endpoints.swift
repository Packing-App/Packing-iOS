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
    
    // MARK: - JOURNEY ENDPOINTS
    
    // 여행 목록 조회
    case getJourneys
    
    // 특정 여행 조회
    case getJourneyById(id: String)
    
    // 새로운 여행 생성
    case createJourney(
        title: String,
        transportType: TransportType,
        origin: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        theme: TravelTheme,
        isPrivate: Bool
    )
    
    // 여행 정보 업데이트
    case updateJourney(
        id: String,
        title: String?,
        transportType: TransportType?,
        origin: String?,
        destination: String?,
        startDate: Date?,
        endDate: Date?,
        theme: TravelTheme?,
        isPrivate: Bool?
    )
    
    // 여행 삭제
    case deleteJourney(id: String)
    
    // 여행에 참가자 초대
    case inviteParticipant(journeyId: String, email: String)
    
    // 여행 참가자 제거
    case removeParticipant(journeyId: String, userId: String)
    
    // 여행 초대 응답 (수락/거절)
    case respondToInvitation(notificationId: String, accept: Bool)
    
    // 여행 추천 준비물 조회
    case getRecommendations(journeyId: String)
    
    
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
            
            // Journey
        case .getJourneys:
            return "/journeys"
        case .getJourneyById(let id):
            return "/journeys/\(id)"
        case .createJourney:
            return "/journeys"
        case .updateJourney(let id, _, _, _, _, _, _, _, _):
            return "/journeys/\(id)"
        case .deleteJourney(let id):
            return "/journeys/\(id)"
        case .inviteParticipant(let journeyId, _):
            return "/journeys/\(journeyId)/participants"
        case .removeParticipant(let journeyId, let userId):
            return "/journeys/\(journeyId)/participants/\(userId)"
        case .respondToInvitation(let notificationId, _):
            return "/journeys/invitations/\(notificationId)"
        case .getRecommendations(let journeyId):
            return "/journeys/\(journeyId)/recommendations"
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
            
            // Journey
        case .getJourneys, .getJourneyById, .getRecommendations:
            return .get
        case .createJourney, .inviteParticipant:
            return .post
        case .updateJourney, .respondToInvitation:
            return .put
        case .deleteJourney, .removeParticipant:
            return .delete
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
            
            // Journey
        case .getJourneys, .getJourneyById, .deleteJourney, .getRecommendations, .removeParticipant:
            return nil
            
        case .createJourney(let title, let transportType, let origin, let destination, let startDate, let endDate, let theme, let isPrivate):
            let dateFormatter = ISO8601DateFormatter()
            return [
                "title": title,
                "transportType": transportType.rawValue,
                "origin": origin,
                "destination": destination,
                "startDate": dateFormatter.string(from: startDate),
                "endDate": dateFormatter.string(from: endDate),
                "theme": theme.rawValue,
                "isPrivate": isPrivate
            ]
            
        case .updateJourney(_, let title, let transportType, let origin, let destination, let startDate, let endDate, let theme, let isPrivate):
            var params: [String: Any] = [:]
            let dateFormatter = ISO8601DateFormatter()
            
            if let title = title { params["title"] = title }
            if let transportType = transportType { params["transportType"] = transportType.rawValue }
            if let origin = origin { params["origin"] = origin }
            if let destination = destination { params["destination"] = destination }
            if let startDate = startDate { params["startDate"] = dateFormatter.string(from: startDate) }
            if let endDate = endDate { params["endDate"] = dateFormatter.string(from: endDate) }
            if let theme = theme { params["theme"] = theme.rawValue }
            if let isPrivate = isPrivate { params["isPrivate"] = isPrivate }
            
            return params
            
        case .inviteParticipant(_, let email):
            return ["email": email]
            
        case .respondToInvitation(_, let accept):
            return ["accept": accept]
            
        default:
            return nil
        }
    }
}
