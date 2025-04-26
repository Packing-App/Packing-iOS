//
//  Theme.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation

struct ThemeListModel: Identifiable {
    let id = UUID()
    let themeName: TravelTheme
    let image: String
}

struct ThemeTemplate: Identifiable, Codable {
    let id: String
    let themeName: String
    let items: [RecommendedItem]
    let createdAt: Date
    let updatedAt: Date
    
    // TravelTheme로 변환하는 계산 속성
    var theme: TravelTheme? {
        return TravelTheme(rawValue: themeName)
    }
    
    init(id: String = UUID().uuidString,
         themeName: TravelTheme,
         items: [RecommendedItem] = [],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.themeName = themeName.rawValue
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case themeName
        case items
        case createdAt
        case updatedAt
    }
}



enum TravelTheme: String, Codable, CaseIterable, Equatable {

    case waterSports = "waterSports"
    case cycling = "cycling"
    case camping = "camping"
    case picnic = "picnic"
    case mountain = "mountain"
    case skiing = "skiing"
    case fishing = "fishing"
    case shopping = "shopping"
    case themepark = "themepark"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .mountain: return "등산"
        case .camping: return "캠핑"
        case .waterSports: return "수상 스포츠"
        case .cycling: return "자전거 타기"
        case .shopping: return "쇼핑"
        case .themepark: return "테마파크"
        case .fishing: return "낚시"
        case .skiing: return "스키"
        case .picnic: return "피크닉"
        case .other: return "기타"
        }
    }
    
    var imageUrl: String {
        return "theme_\(self.rawValue)"
    }
}

enum ItemCategory: String, Codable, CaseIterable, Equatable {
    case clothing = "clothing"
    case electronics = "electronics"
    case toiletries = "toiletries"
    case documents = "documents"
    case medicines = "medicines"
    case essentials = "essentials"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .clothing: return "의류"
        case .electronics: return "전자기기"
        case .toiletries: return "세면도구"
        case .documents: return "서류"
        case .medicines: return "의약품"
        case .essentials: return "필수품"
        case .other: return "기타"
        }
    }
}

extension ThemeListModel {
    static let examples: [ThemeListModel] = [
        ThemeListModel(themeName: .waterSports, image: "waterSports"),
        ThemeListModel(themeName: .cycling, image: "cycling"),
        ThemeListModel(themeName: .camping, image: "camping"),
        ThemeListModel(themeName: .picnic, image: "picnic"),
        ThemeListModel(themeName: .mountain, image: "mountain"),
        ThemeListModel(themeName: .skiing, image: "skiing"),
        ThemeListModel(themeName: .fishing, image: "fishing"),
        ThemeListModel(themeName: .shopping, image: "shopping"),
        ThemeListModel(themeName: .themepark, image: "themepark")
    ]
}
