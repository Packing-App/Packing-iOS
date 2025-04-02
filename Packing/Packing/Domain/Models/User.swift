//
//  User.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation

struct User: Codable, Equatable {
    let id: String
    let name: String
    let email: String
//    let password: Int
    let profileImage: String?
    let intro: String
    let socialType: LoginType
    let socialId: String?
//    let refreshToken: String?
//    let pushNotificationEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case profileImage
        case intro
        case socialType
        case socialId
    }
}

enum LoginType: String, Codable {
    case email
    case apple
    case google
    case kakao
    case naver
}


extension User {
    static let exampleUser = User(
        id: UUID().uuidString,
        name: "라라",
        email: "rsdbddml@gmail.com",
        profileImage: "demoUserProfileImage",
        intro: "세계일주를 꿈꾸는 라라, 두 번째 여행 시작!",
        socialType: .naver,
        socialId: "dbddml631@naver.com"
    )
}
