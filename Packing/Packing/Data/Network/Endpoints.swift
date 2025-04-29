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
        if method == .get && parameters != nil && !parameters!.isEmpty {
            var components = URLComponents(string: baseURL + path)
            components?.queryItems = parameters?.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
            return components?.url
        }
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
    
    // MARK: - LOCATION ENDPOINTS
    // 도시 검색 (자동완성)
    case searchLocations(query: String, limit: Int)

    // 도시 영문명 변환
    case translateCity(city: String)

    // 도시 날씨 정보 조회
    case getCityWeather(city: String, date: Date?)

    // 여행 기간 내 날씨 정보 조회
    case getJourneyForecast(city: String, startDate: Date, endDate: Date)
    
    
    // MARK: - PACKING ITEM ENDPOINTS
    
    // 여행별 준비물 목록 조회
    case getPackingItemsByJourney(journeyId: String)
    
    // 준비물 생성
    case createPackingItem(
        journeyId: String,
        name: String,
        count: Int,
        category: ItemCategory,
        isShared: Bool,
        assignedTo: String?
    )
    
    // 준비물 일괄 생성 (테마 템플릿에서 가져오기)
    case createBulkPackingItems(
        journeyId: String,
        templateName: String,
        selectedItems: [String],
        mergeDuplicates: Bool
    )
    
    // 추천 준비물에서 선택한 준비물들을 일괄 등록
    case createSelectedRecommendedItems(
        journeyId: String,
        selectedItems: [SelectedRecommendedItem],
        mergeDuplicates: Bool
    )
    
    // 준비물 업데이트
    case updatePackingItem(
        id: String,
        name: String?,
        count: Int?,
        category: ItemCategory?,
        isShared: Bool?,
        assignedTo: String?
    )
    
    // 준비물 체크 상태 토글
    case togglePackingItem(id: String)
    
    // 준비물 삭제
    case deletePackingItem(id: String)
    
    // 카테고리별 준비물 조회
    case getPackingItemsByCategory(journeyId: String)
    
    // 테마별 준비물 템플릿 목록 조회
    case getThemeTemplates
    
    // 특정 테마의 준비물 템플릿 조회
    case getThemeTemplateByName(themeName: String)
    
    // MARK: - FRIENDSHIP ENDPOINTS

    // 친구 목록 조회
    case getFriends
        
    // 친구 요청 목록 조회
    case getFriendRequests
        
    // 친구 요청 보내기
    case sendFriendRequest(email: String)
        
    // 친구 요청 응답 (수락/거절)
    case respondToFriendRequest(id: String, accept: Bool)
        
    // 친구 삭제
    case removeFriend(id: String)
        
    // 이메일로 친구 검색
    case searchFriendByEmail(email: String)
    
    // MARK: - DEVICE
    case updateDeviceToken(token: String)
    case updatePushSettings(enabled: Bool)
    case sendTestNotification
    case removeDeviceToken

    // MARK: - NOTIFICATION
    case getNotifications
    case markNotificationAsRead(id: String)
    case markAllNotificationsAsRead
    case deleteNotification(id: String)
    case getUnreadCount
    case createJourneyReminder(journeyId: String)
    case createWeatherAlert(journeyId: String)
    
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
        case .searchLocations:
            return "/locations/search"
        case .translateCity:
            return "/locations/translate"
        case .getCityWeather(let city, _):
            return "/locations/\(city)/weather"
        case .getJourneyForecast(let city, _, _):
            return "/locations/\(city)/forecast"
            
            // Packing Item
        case .getPackingItemsByJourney(let journeyId):
            return "/packing-items/journey/\(journeyId)"
        case .createPackingItem:
            return "/packing-items"
        case .createBulkPackingItems:
            return "/packing-items/bulk"
        case .createSelectedRecommendedItems:
            return "/packing-items/from-recommendations"
        case .updatePackingItem(let id, _, _, _, _, _):
            return "/packing-items/\(id)"
        case .togglePackingItem(let id):
            return "/packing-items/\(id)/toggle"
        case .deletePackingItem(let id):
            return "/packing-items/\(id)"
        case .getPackingItemsByCategory(let journeyId):
            return "/packing-items/categories/\(journeyId)"
        case .getThemeTemplates:
            return "/packing-items/templates"
        case .getThemeTemplateByName(let themeName):
            return "/packing-items/templates/\(themeName)"
            // Friendship
        case .getFriends:
            return "/friendships"
        case .getFriendRequests:
            return "/friendships/requests"
        case .sendFriendRequest:
            return "/friendships/requests"
        case .respondToFriendRequest(let id, _):
            return "/friendships/requests/\(id)"
        case .removeFriend(let id):
            return "/friendships/\(id)"
        case .searchFriendByEmail:
            return "/friendships/search"

            
            // 디바이스 관련
        case .updateDeviceToken:
            return "/devices/token"
        case .updatePushSettings:
            return "/devices/push-settings"
        case .sendTestNotification:
            return "/devices/test-notification"
        case .removeDeviceToken:
            return "/devices/token"
            
            // 알림 관련
        case .getNotifications:
            return "/notifications"
        case .markNotificationAsRead(let id):
            return "/notifications/\(id)/read"
        case .markAllNotificationsAsRead:
            return "/notifications/read-all"
        case .deleteNotification(let id):
            return "/notifications/\(id)"
        case .getUnreadCount:
            return "/notifications/unread/count"
        case .createJourneyReminder:
            return "/notifications/journey-reminder"
        case .createWeatherAlert:
            return "/notifications/weather-alert"
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
        case .searchLocations, .translateCity, .getCityWeather, .getJourneyForecast:
            return .get
            
            // Packing Item
        case .getPackingItemsByJourney, .getPackingItemsByCategory, .getThemeTemplates, .getThemeTemplateByName:
            return .get
        case .createPackingItem, .createBulkPackingItems, .createSelectedRecommendedItems:
            return .post
        case .updatePackingItem, .togglePackingItem:
            return .put
        case .deletePackingItem:
            return .delete
            
            // Friendship
        case .getFriends, .getFriendRequests, .searchFriendByEmail:
            return .get
        case .sendFriendRequest:
            return .post
        case .respondToFriendRequest:
            return .put
        case .removeFriend:
            return .delete
            // 디바이스 관련
        case .updateDeviceToken, .updatePushSettings:
            return .put
        case .sendTestNotification:
            return .post
        case .removeDeviceToken:
            return .delete
            
            // 알림 관련
        case .getNotifications, .getUnreadCount:
            return .get
        case .markNotificationAsRead, .markAllNotificationsAsRead:
            return .put
        case .deleteNotification:
            return .delete
        case .createJourneyReminder, .createWeatherAlert:
            return .post
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
            // Location
            
        case .searchLocations(let query, let limit):
            return ["query": query, "limit": limit]
            
        case .translateCity(let city):
            return ["city": city]
        case .getCityWeather(_, let date):
            if let date = date {
                let dateFormatter = ISO8601DateFormatter()
                return ["date": dateFormatter.string(from: date)]
            }
            return nil
        case .getJourneyForecast(_, let startDate, let endDate):
            let dateFormatter = ISO8601DateFormatter()
            return [
                "startDate": dateFormatter.string(from: startDate),
                "endDate": dateFormatter.string(from: endDate)
            ]
            
        // Packing Items
        case .getPackingItemsByJourney, .getPackingItemsByCategory, .getThemeTemplates, .getThemeTemplateByName, .togglePackingItem, .deletePackingItem:
            return nil
            
        case .createPackingItem(let journeyId, let name, let count, let category, let isShared, let assignedTo):
            var params: [String: Any] = [
                "journeyId": journeyId,
                "name": name,
                "count": count,
                "category": category.rawValue,
                "isShared": isShared
            ]
            
            if let assignedTo = assignedTo {
                params["assignedTo"] = assignedTo
            }
            
            // 기본값 추가
            params["mergeDuplicates"] = true
            
            return params
            
        case .createBulkPackingItems(let journeyId, let templateName, let selectedItems, let mergeDuplicates):
            return [
                "journeyId": journeyId,
                "templateName": templateName,
                "selectedItems": selectedItems,
                "mergeDuplicates": mergeDuplicates
            ]
            
        case .createSelectedRecommendedItems(let journeyId, let selectedItems, let mergeDuplicates):
            return [
                "journeyId": journeyId,
                "selectedItems": selectedItems.map { item in
                    [
                        "name": item.name,
                        "category": item.category,
                        "count": item.count
                    ]
                },
                "mergeDuplicates": mergeDuplicates
            ]
            
        case .updatePackingItem(_, let name, let count, let category, let isShared, let assignedTo):
            var params: [String: Any] = [:]
            
            if let name = name { params["name"] = name }
            if let count = count { params["count"] = count }
            if let category = category { params["category"] = category.rawValue }
            if let isShared = isShared { params["isShared"] = isShared }
            if let assignedTo = assignedTo { params["assignedTo"] = assignedTo }
            
            return params
            
            // Friendship
        case .getFriends, .getFriendRequests:
            return nil
        case .sendFriendRequest(let email):
            return ["email": email]
        case .respondToFriendRequest(_, let accept):
            return ["accept": accept]
        case .removeFriend:
            return nil
        case .searchFriendByEmail(let email):
            return ["email": email]
            
            
            
            // 디바이스 관련
        case .updateDeviceToken(let token):
            return ["deviceToken": token, "deviceType": "ios"]
        case .updatePushSettings(let enabled):
            return ["enabled": enabled]
//        case .sendTestNotification, .removeDeviceToken:
//            return nil
            
            // 알림 관련
//        case .getNotifications, .markNotificationAsRead, .markAllNotificationsAsRead,
//                .deleteNotification, .getUnreadCount:
//            return nil
            
        case .createJourneyReminder(let journeyId), .createWeatherAlert(let journeyId):
            return ["journeyId": journeyId]
            
        default:
            return nil
        }
    }
}
