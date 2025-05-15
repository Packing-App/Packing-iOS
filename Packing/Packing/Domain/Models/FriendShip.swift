//
//  FriendShip.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import Foundation

// MARK: - 친구 관계 모델
struct Friendship: Codable, Identifiable {
    let id: String
    let requesterId: String
    let receiverId: String
    let status: FriendshipStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case requesterId
        case receiverId
        case status
        case createdAt
        case updatedAt
    }
}

// MARK: - 친구 관계 상태
enum FriendshipStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}

// MARK: - 친구 목록 조회 응답의 Friend 항목
struct Friend: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let email: String
    let profileImage: String?
    let intro: String?
    let friendshipId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case profileImage
        case intro
        case friendshipId
    }
}

// MARK: - 간소화된 사용자 정보
struct UserInfo: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let email: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case profileImage
    }
}

// MARK: - 받은 친구 요청 항목
struct ReceivedFriendRequest: Codable, Identifiable, Equatable {
    let id: String
    let requesterId: UserInfo?  // 요청한 사용자의 정보 (객체)
    let receiverId: String     // 현재 사용자 ID (문자열)
    let status: FriendshipStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case requesterId
        case receiverId
        case status
        case createdAt
        case updatedAt
    }
}

// MARK: - 보낸 친구 요청 항목
struct SentFriendRequest: Codable, Identifiable, Equatable {
    let id: String
    let requesterId: String    // 현재 사용자 ID (문자열)
    let receiverId: UserInfo?   // 요청 받은 사용자의 정보 (객체)
    let status: FriendshipStatus
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case requesterId
        case receiverId
        case status
        case createdAt
        case updatedAt
    }
}


// MARK: - 친구 검색 결과 항목
struct FriendSearchResult: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let email: String
    let profileImage: String?
    var friendshipStatus: FriendshipStatus?
    var friendshipId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case profileImage
        case friendshipStatus
        case friendshipId
    }
}
