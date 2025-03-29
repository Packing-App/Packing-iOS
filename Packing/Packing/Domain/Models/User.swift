//
//  User.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation

struct User {
    let name: String
    let email: String
//    let password: Int
    let profileImage: String?
    let socialType: LoginType
    let socialId: String?
//    let refreshToken: String?
//    let pushNotificationEnabled: Bool
}

enum LoginType: String {
    case email
    case kakao
    case naver
    case google
    case apple
}
