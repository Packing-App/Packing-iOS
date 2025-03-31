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
//    let intro: String
    let socialType: LoginType
    let socialId: String?
//    let refreshToken: String?
//    let pushNotificationEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case profileImage
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
