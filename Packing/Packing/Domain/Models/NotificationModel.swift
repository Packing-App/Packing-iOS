//
//  Notification.swift
//  Packing
//
//  Created by 이융의 on 4/20/25.
//

import Foundation

struct NotificationModel: Identifiable, Codable {
    let id: String
    let userId: String
    let journeyId: String?
    let type: NotificationType
    let content: String
    let isRead: Bool
    let scheduledAt: Date?
    let createdAt: Date
}

enum NotificationType: String, Codable {
    case invitation = "invitation"
    case weather = "weather"
    case reminder = "reminder"
}
