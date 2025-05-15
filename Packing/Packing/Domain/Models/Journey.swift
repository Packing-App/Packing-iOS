//
//  Journey.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation


// 여행 교통 수단 열거형
enum TransportType: String, Codable, CaseIterable {
    case plane = "plane"
    case train = "train"
    case ship = "ship"
    case bus = "bus"
    case walk = "walk"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .plane: return "비행기".localized
        case .train: return "기차".localized
        case .ship: return "배".localized
        case .bus: return "버스".localized
        case .walk: return "도보".localized
        case .other: return "기타".localized
        }
    }
}


struct Journey: Identifiable, Codable {
    let id: String
    let creatorId: String   // 생성자 ID
    let title: String       // 여행 제목
    let transportType: TransportType
    let origin: String      // 출발지
    let destination: String // 도착지
    let startDate: Date
    let endDate: Date
    let themes: [TravelTheme]
    let imageUrl: String?
    let isPrivate: Bool
    let participants: [User]  // 여행 참가자 ID 목록
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case creatorId, title, transportType, origin, destination
        case startDate, endDate, themes, imageUrl, isPrivate, participants
        case createdAt, updatedAt
    }
}

extension Journey: Equatable {
    
}


// 예시 여행 데이터
extension Journey {
    
    // 여행 기간 계산 (일 수)
    var durationDays: Int {
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    // 여행 시작까지 남은 일 수
    var daysUntilStart: Int {
        return max(0, Calendar.current.dateComponents([.day], from: Date(), to: startDate).day ?? 0)
    }
    
    // 간단한 문자열 형식의 여행 기간
    var dateRangeString: String {
        let startString = DateFormatter.journeyDateFormatter.string(from: startDate)
        let endString = DateFormatter.journeyDateFormatter.string(from: endDate)
        return "\(startString) ~ \(endString)"
    }
}
