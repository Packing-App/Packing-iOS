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
    case invitation = "invitation"                        // 여행 초대
    case journeyInvitationResponse = "journeyInvitationResponse"  // 여행 초대 응답
    case weather = "weather"                              // 날씨 알림
    case reminder = "reminder"                            // 일정 알림
    case friendRequest = "friendRequest"                  // 친구 요청
    case friendRequestResponse = "friendRequestResponse"  // 친구 요청 응답
}
