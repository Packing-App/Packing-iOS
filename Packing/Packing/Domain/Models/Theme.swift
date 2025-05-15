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
        case .mountain: return "등산".localized
        case .camping: return "캠핑".localized
        case .waterSports: return "수상 스포츠".localized
        case .cycling: return "자전거 타기".localized
        case .shopping: return "쇼핑".localized
        case .themepark: return "테마파크".localized
        case .fishing: return "낚시".localized
        case .skiing: return "스키".localized
        case .picnic: return "피크닉".localized
        case .business: return "출장/비즈니스".localized
        case .beach: return "해변 휴양".localized
        case .cultural: return "문화/역사 탐방".localized
        case .photography: return "사진 여행".localized
        case .family: return "가족 여행".localized
        case .backpacking: return "배낭여행".localized
        case .wellness: return "스파/힐링".localized
        case .safari: return "사파리".localized
        case .cruise: return "크루즈".localized
        case .desert: return "사막 여행".localized
        case .sports: return "스포츠 경기관람".localized
        case .roadtrip: return "자동차 여행".localized
        case .study: return "어학연수".localized
        case .glamping: return "글램핑".localized
        case .medical: return "의료 관광".localized
        case .adventure: return "익스트림".localized
        case .diving: return "다이빙".localized
        case .music: return "음악 축제".localized
        case .wine: return "와인 투어".localized
        case .urban: return "도시 관광".localized
        case .island: return "섬 여행".localized
        case .other: return "기타".localized
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
        case .clothing: return "의류".localized
        case .electronics: return "전자기기".localized
        case .toiletries: return "세면도구".localized
        case .documents: return "서류".localized
        case .medicines: return "의약품".localized
        case .essentials: return "필수품".localized
        case .other: return "기타".localized
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
