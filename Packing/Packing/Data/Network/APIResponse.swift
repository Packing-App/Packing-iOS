//
//  APIResponse.swift
//  Packing
//
//  Created by 이융의 on 5/14/25.
//

import Foundation

// MARK: - API Response 모델

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: T?
    let status: Int?
}

struct UserResponse: Codable {
    let user: User
}

struct ProfileImageResponse: Codable {
    let profileImage: String
}

struct TokenData: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct RefreshTokenResponse: Codable {
    let accessToken: String
}

struct RecommendationResponse: Codable {
    let journey: Journey
    let categories: [String: RecommendationCategory]
}

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - 친구 요청 목록 응답
struct FriendRequestsResponse: Codable {
    let received: [ReceivedFriendRequest]
    let sent: [SentFriendRequest]
}


// MARK: - 디바이스 토큰 응답
struct DeviceTokenResponse: Codable {
    let deviceToken: String
    let deviceType: String
    let pushNotificationEnabled: Bool
}

// MARK: - 푸시 설정 응답
struct PushSettingsResponse: Codable {
    let pushNotificationEnabled: Bool
}

struct EmptyResponse: Codable {}
