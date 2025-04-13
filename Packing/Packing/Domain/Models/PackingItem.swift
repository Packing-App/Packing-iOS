//
//  PackingItem.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation

// MARK: - PackingItem Model
struct PackingItem: Identifiable, Codable {
    let id: String
    let journeyId: String
    let name: String
    let count: Int
    var isChecked: Bool
    let category: ItemCategory
    let isShared: Bool
    let assignedTo: String?
    let createdBy: String
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        journeyId: String,
        name: String,
        count: Int = 1,
        isChecked: Bool = false,
        category: ItemCategory,
        isShared: Bool = false,
        assignedTo: String? = nil,
        createdBy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.journeyId = journeyId
        self.name = name
        self.count = count
        self.isChecked = isChecked
        self.category = category
        self.isShared = isShared
        self.assignedTo = assignedTo
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// 샘플 데이터 생성을 위한 확장 (업데이트된 버전)
extension PackingItem {
    static let examples: [PackingItem] = [
        // 여행 1 (플리트비체 국립공원) 아이템 - 개인 준비물
        PackingItem(
            id: "item1",
            journeyId: "journey1",
            name: "등산화",
            count: 1,
            isChecked: true,
            category: .clothing,
            isShared: false,
            createdBy: User.currentUser.id
        ),
        PackingItem(
            id: "item2",
            journeyId: "journey1",
            name: "바람막이",
            count: 1,
            isChecked: false,
            category: .clothing,
            isShared: false,
            createdBy: User.currentUser.id
        ),
        PackingItem(
            id: "item3",
            journeyId: "journey1",
            name: "여권",
            count: 1,
            isChecked: true,
            category: .documents,
            isShared: false,
            createdBy: User.currentUser.id
        ),
        
        // 여행 1 (플리트비체 국립공원) - 공용 준비물
        PackingItem(
            id: "item4",
            journeyId: "journey1",
            name: "카메라",
            count: 1,
            isChecked: false,
            category: .electronics,
            isShared: true,
            assignedTo: User.currentUser.id,
            createdBy: User.currentUser.id
        ),
        PackingItem(
            id: "item5",
            journeyId: "journey1",
            name: "비상약",
            count: 1,
            isChecked: true,
            category: .medicines,
            isShared: true,
            assignedTo: User.exampleUser.id,
            createdBy: User.currentUser.id
        ),
        
        // 여행 2 (다낭 해변) 아이템 - 개인 준비물
        PackingItem(
            id: "item6",
            journeyId: "journey2",
            name: "수영복",
            count: 2,
            isChecked: true,
            category: .clothing,
            isShared: false,
            createdBy: User.currentUser.id
        ),
        PackingItem(
            id: "item7",
            journeyId: "journey2",
            name: "비치타올",
            count: 2,
            isChecked: true,
            category: .essentials,
            isShared: false,
            createdBy: User.currentUser.id
        ),
        PackingItem(
            id: "item8",
            journeyId: "journey2",
            name: "선크림",
            count: 1,
            isChecked: false,
            category: .toiletries,
            isShared: false,
            createdBy: User.currentUser.id
        ),
        
        // 여행 2 (다낭 해변) - 공용 준비물
        PackingItem(
            id: "item9",
            journeyId: "journey2",
            name: "선글라스",
            count: 1,
            isChecked: true,
            category: .essentials,
            isShared: true,
            assignedTo: User.currentUser.id,
            createdBy: User.currentUser.id
        ),
        PackingItem(
            id: "item10",
            journeyId: "journey2",
            name: "방수팩",
            count: 1,
            isChecked: false,
            category: .essentials,
            isShared: true,
            assignedTo: User.exampleUser.id,
            createdBy: User.currentUser.id
        ),
        
        // 여행 3 (후지산) 아이템 - 개인 준비물
        PackingItem(
            id: "item11",
            journeyId: "journey3",
            name: "등산복",
            count: 1,
            isChecked: true,
            category: .clothing,
            isShared: false,
            createdBy: User.currentUser.id
        ),
        PackingItem(
            id: "item12",
            journeyId: "journey3",
            name: "등산스틱",
            count: 1,
            isChecked: false,
            category: .essentials,
            isShared: false,
            createdBy: User.currentUser.id
        ),
        
        // 여행 3 (후지산) - 공용 준비물
        PackingItem(
            id: "item13",
            journeyId: "journey3",
            name: "보온물통",
            count: 1,
            isChecked: true,
            category: .essentials,
            isShared: true,
            assignedTo: User.currentUser.id,
            createdBy: User.currentUser.id
        )
    ]
    
    // 특정 여행의 준비물 목록을 가져오는 메서드
    static func itemsForJourney(id: String) -> [PackingItem] {
        return examples.filter { $0.journeyId == id }
    }
    
    // 아이템 카테고리별로 그룹화하는 메서드
    static func groupedByCategory(items: [PackingItem]) -> [ItemCategory: [PackingItem]] {
        Dictionary(grouping: items) { $0.category }
    }
    
    // 체크된 아이템 수 계산 메서드
    static func checkedItemsCount(items: [PackingItem]) -> Int {
        items.filter { $0.isChecked }.count
    }
}
