//
//  PackingItem.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation

// MARK: - Recommendation Models

struct RecommendationCategory: Codable, Equatable {
    let name: String    // 여행 테마
    let items: [RecommendedItem]
}

struct RecommendedItem: Codable, Equatable {
    let name: String
    let category: String
    let isEssential: Bool
    let count: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case category
        case isEssential
        case count
    }
    
    init(name: String, category: String, isEssential: Bool, count: Int? = 0) {
        self.name = name
        self.category = category
        self.isEssential = isEssential
        self.count = count
    }
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

extension PackingItem {
    // 아이템 카테고리별로 그룹화하는 메서드
    static func groupedByCategory(items: [PackingItem]) -> [ItemCategory: [PackingItem]] {
        Dictionary(grouping: items) { $0.category }
    }
    
    // 체크된 아이템 수 계산 메서드
    static func checkedItemsCount(items: [PackingItem]) -> Int {
        items.filter { $0.isChecked }.count
    }
}
