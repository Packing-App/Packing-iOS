//
//  Notification.swift
//  Packing
//
//  Created by 이융의 on 4/20/25.
//

import Foundation

struct NotificationModel: Identifiable, Codable, Equatable {
    let id: String?
    let userId: String
    let journeyId: String?
    let type: NotificationType
    let content: String
    let isRead: Bool
    let scheduledAt: Date?
    let createdAt: Date
    
    // CodingKeys를 사용하여 서버 응답의 _id를 id로 매핑
    enum CodingKeys: String, CodingKey {
        case id = "_id"    // 서버에서는 _id로 오지만 모델에서는 id로 사용
        case userId
        case journeyId
        case type
        case content
        case isRead
        case scheduledAt
        case createdAt
    }
}


enum NotificationType: String, Codable {
    case invitation = "invitation"
    case weather = "weather"
    case reminder = "reminder"
}


// 디바이스 토큰 응답
struct DeviceTokenResponse: Codable {
    let deviceToken: String
    let deviceType: String
    let pushNotificationEnabled: Bool
}

// 푸시 설정 응답
struct PushSettingsResponse: Codable {
    let pushNotificationEnabled: Bool
}
