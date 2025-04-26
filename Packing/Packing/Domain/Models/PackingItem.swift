//
//  PackingItem.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation



// MARK: - Recommendation Models

struct RecommendationCategory: Codable, Equatable {
    let name: String
    let items: [RecommendedItem]
}

struct RecommendedItem: Codable, Identifiable, Equatable {
    var id: String { name }  // 아이템 이름을 ID로 사용
    let name: String
    let category: String    // ItemCategory
    let isEssential: Bool
    let count: Int?
}

// 여행 추가 -> 추천 아이템 -> 추천 아이템 중 select (다음: -> packing item 으로 가기 위한 중간 과정)
// 선택된 준비물 아이템 모델
struct SelectedRecommendedItem: Codable {
    let name: String
    let category: String
    let count: Int
    
    init(name: String, category: String, count: Int = 1) {
        self.name = name
        self.category = category
        self.count = count
    }
}

// MARK: - PackingItem Model

struct PackingItem: Identifiable, Codable, Equatable {
    let id: String
    let journeyId: String
    let name: String
    let count: Int
    var isChecked: Bool
    let category: ItemCategory
    let isShared: Bool
    let assignedTo: User?
    let createdBy: User
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case journeyId, name, count, isChecked
        case category, isShared
        case assignedTo, createdBy
        case createdAt, updatedAt
    }
}
//
extension PackingItem {
//    static let examples: [PackingItem] = [
//        // 여행 1 (플리트비체 국립공원) 아이템 - 개인 준비물
//        PackingItem(
//            id: "item1",
//            journeyId: "journey1",
//            name: "등산화",
//            count: 1,
//            isChecked: true,
//            category: .clothing,
//            isShared: false,
//            createdBy: User.currentUser.id
//        ),
//        PackingItem(
//            id: "item2",
//            journeyId: "journey1",
//            name: "바람막이",
//            count: 1,
//            isChecked: false,
//            category: .clothing,
//            isShared: false,
//            createdBy: User.currentUser.id
//        ),
//        PackingItem(
//            id: "item3",
//            journeyId: "journey1",
//            name: "여권",
//            count: 1,
//            isChecked: true,
//            category: .documents,
//            isShared: false,
//            createdBy: User.currentUser.id
//        ),
//        
//        // 여행 1 (플리트비체 국립공원) - 공용 준비물
//        PackingItem(
//            id: "item4",
//            journeyId: "journey1",
//            name: "카메라",
//            count: 1,
//            isChecked: false,
//            category: .electronics,
//            isShared: true,
//            assignedTo: User.currentUser.id,
//            createdBy: User.currentUser.id
//        ),
//        PackingItem(
//            id: "item5",
//            journeyId: "journey1",
//            name: "비상약",
//            count: 1,
//            isChecked: true,
//            category: .medicines,
//            isShared: true,
//            assignedTo: User.exampleUser.id,
//            createdBy: User.currentUser.id
//        ),
//        
//        // 여행 2 (다낭 해변) 아이템 - 개인 준비물
//        PackingItem(
//            id: "item6",
//            journeyId: "journey2",
//            name: "수영복",
//            count: 2,
//            isChecked: true,
//            category: .clothing,
//            isShared: false,
//            createdBy: User.currentUser.id
//        ),
//        PackingItem(
//            id: "item7",
//            journeyId: "journey2",
//            name: "비치타올",
//            count: 2,
//            isChecked: true,
//            category: .essentials,
//            isShared: false,
//            createdBy: User.currentUser.id
//        ),
//        PackingItem(
//            id: "item8",
//            journeyId: "journey2",
//            name: "선크림",
//            count: 1,
//            isChecked: false,
//            category: .toiletries,
//            isShared: false,
//            createdBy: User.currentUser.id
//        ),
//        
//        // 여행 2 (다낭 해변) - 공용 준비물
//        PackingItem(
//            id: "item9",
//            journeyId: "journey2",
//            name: "선글라스",
//            count: 1,
//            isChecked: true,
//            category: .essentials,
//            isShared: true,
//            assignedTo: User.currentUser.id,
//            createdBy: User.currentUser.id
//        ),
//        PackingItem(
//            id: "item10",
//            journeyId: "journey2",
//            name: "방수팩",
//            count: 1,
//            isChecked: false,
//            category: .essentials,
//            isShared: true,
//            assignedTo: User.exampleUser.id,
//            createdBy: User.currentUser.id
//        ),
//        
//        // 여행 3 (후지산) 아이템 - 개인 준비물
//        PackingItem(
//            id: "item11",
//            journeyId: "journey3",
//            name: "등산복",
//            count: 1,
//            isChecked: true,
//            category: .clothing,
//            isShared: false,
//            createdBy: User.currentUser.id
//        ),
//        PackingItem(
//            id: "item12",
//            journeyId: "journey3",
//            name: "등산스틱",
//            count: 1,
//            isChecked: false,
//            category: .essentials,
//            isShared: false,
//            createdBy: User.currentUser.id
//        ),
//        
//        // 여행 3 (후지산) - 공용 준비물
//        PackingItem(
//            id: "item13",
//            journeyId: "journey3",
//            name: "보온물통",
//            count: 1,
//            isChecked: true,
//            category: .essentials,
//            isShared: true,
//            assignedTo: User.currentUser.id,
//            createdBy: User.currentUser.id
//        )
//    ]
//    
//    // 특정 여행의 준비물 목록을 가져오는 메서드
//    static func itemsForJourney(id: String) -> [PackingItem] {
//        return examples.filter { $0.journeyId == id }
//    }
//    
    // 아이템 카테고리별로 그룹화하는 메서드
    static func groupedByCategory(items: [PackingItem]) -> [ItemCategory: [PackingItem]] {
        Dictionary(grouping: items) { $0.category }
    }
    
    // 체크된 아이템 수 계산 메서드
    static func checkedItemsCount(items: [PackingItem]) -> Int {
        items.filter { $0.isChecked }.count
    }
}
