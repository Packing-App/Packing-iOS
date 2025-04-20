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
        case .plane: return "비행기"
        case .train: return "기차"
        case .ship: return "배"
        case .bus: return "버스"
        case .walk: return "도보"
        case .other: return "기타"
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
    let theme: TravelTheme
    let imageUrl: String?
    let isPrivate: Bool
    let participants: [User]  // 여행 참가자 ID 목록
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // 몽고DB의 _id를 Swift의 id로 매핑
        case creatorId, title, transportType, origin, destination
        case startDate, endDate, theme, imageUrl, isPrivate, participants
        case createdAt, updatedAt
    }
}

extension Journey: Equatable {
    
}


// 예시 여행 데이터
extension Journey {
    static let examples: [Journey] = [
        Journey(
            id: "journey3",
            creatorId: User.currentUser.id,
            title: "후지산 등반",
            transportType: .train,
            origin: "도쿄",
            destination: "일본 후지산",
            startDate: DateFormatter.journeyDateFormatter.date(from: "2024-04-10")!,
            endDate: DateFormatter.journeyDateFormatter.date(from: "2024-04-15")!,
            theme: .mountain,
            imageUrl: "journey_fujisan",
            isPrivate: false,
            participants: [User.currentUser, User.exampleUser,User.exampleUser2],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Journey(
            id: "journey1",
            creatorId: User.currentUser.id,
            title: "플리트비체 국립공원 탐험",
            transportType: .walk,
            origin: "서울",
            destination: "크로아티아 플리트비체",
            startDate: DateFormatter.journeyDateFormatter.date(from: "2023-12-01")!,
            endDate: DateFormatter.journeyDateFormatter.date(from: "2023-12-07")!,
            theme: .themepark,
            imageUrl: "journey_plitvice",
            isPrivate: false,
            participants: [User.currentUser],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Journey(
            id: "journey2",
            creatorId: User.currentUser.id,
            title: "다낭 해변 휴가",
            transportType: .plane,
            origin: "인천",
            destination: "베트남 다낭",
            startDate: DateFormatter.journeyDateFormatter.date(from: "2024-01-15")!,
            endDate: DateFormatter.journeyDateFormatter.date(from: "2024-01-22")!,
            theme: .waterSports,
            imageUrl: "journey_danang",
            isPrivate: false,
            participants: [User.currentUser, User.exampleUser],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Journey(
            id: "journey5",
            creatorId: User.currentUser.id,
            title: "제주도 캠핑",
            transportType: .plane,
            origin: "김포",
            destination: "제주도",
            startDate: DateFormatter.journeyDateFormatter.date(from: "2024-05-20")!,
            endDate: DateFormatter.journeyDateFormatter.date(from: "2024-05-25")!,
            theme: .camping,
            imageUrl: "journey_jeju",
            isPrivate: true,
            participants: [User.exampleUser],
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    // 현재 사용자의 여행 목록
    static var currentUserJourneys: [Journey] {
        return examples.filter {
            $0.creatorId == User.currentUser.id ||
            $0.participants.contains(User.currentUser)
        }
    }
    
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
