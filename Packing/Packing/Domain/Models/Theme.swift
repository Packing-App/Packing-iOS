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
    case business = "business"
    case beach = "beach"
    case cultural = "cultural"
    case photography = "photography"
    case family = "family"
    case backpacking = "backpacking"
    case wellness = "wellness"
    case safari = "safari"
    case cruise = "cruise"
    case desert = "desert"
    case sports = "sports"
    case roadtrip = "roadtrip"
    case study = "study"
    case glamping = "glamping"
    case medical = "medical"
    case adventure = "adventure"
    case diving = "diving"
    case music = "music"
    case wine = "wine"
    case urban = "urban"
    case island = "island"
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
        case .business: return "출장/비즈니스"
        case .beach: return "해변 휴양"
        case .cultural: return "문화/역사 탐방"
        case .photography: return "사진 여행"
        case .family: return "가족 여행"
        case .backpacking: return "배낭여행"
        case .wellness: return "스파/힐링"
        case .safari: return "사파리"
        case .cruise: return "크루즈"
        case .desert: return "사막 여행"
        case .sports: return "스포츠"
        case .roadtrip: return "자동차 여행"
        case .study: return "어학연수"
        case .glamping: return "글램핑"
        case .medical: return "의료 관광"
        case .adventure: return "모험 스포츠"
        case .diving: return "다이빙"
        case .music: return "음악 축제"
        case .wine: return "와인 투어"
        case .urban: return "도시 관광"
        case .island: return "섬 여행"
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
        ThemeListModel(themeName: .themepark, image: "themepark"),
        ThemeListModel(themeName: .business, image: "business"),
        ThemeListModel(themeName: .beach, image: "beach"),
        ThemeListModel(themeName: .cultural, image: "cultural"),
        ThemeListModel(themeName: .photography, image: "photography"),
        ThemeListModel(themeName: .family, image: "family"),
        ThemeListModel(themeName: .backpacking, image: "backpacking"),
        ThemeListModel(themeName: .wellness, image: "wellness"),
        ThemeListModel(themeName: .safari, image: "safari"),
        ThemeListModel(themeName: .cruise, image: "cruise"),
        ThemeListModel(themeName: .desert, image: "desert"),
        ThemeListModel(themeName: .sports, image: "sports"),
        ThemeListModel(themeName: .roadtrip, image: "roadtrip"),
        ThemeListModel(themeName: .study, image: "study"),
        ThemeListModel(themeName: .glamping, image: "glamping"),
        ThemeListModel(themeName: .medical, image: "medical"),
        ThemeListModel(themeName: .adventure, image: "adventure"),
        ThemeListModel(themeName: .diving, image: "diving"),
        ThemeListModel(themeName: .music, image: "music"),
        ThemeListModel(themeName: .wine, image: "wine"),
        ThemeListModel(themeName: .urban, image: "urban"),
        ThemeListModel(themeName: .island, image: "island"),
        ThemeListModel(themeName: .other, image: "other")
    ]
}
