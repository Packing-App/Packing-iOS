//
//  Theme.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation


// 여행 테마 템플릿 구조체
struct ThemeTemplate: Identifiable, Codable {
    let id: String
    let themeName: TravelTheme
    let image: String
    let items: [Item]
    let createdAt: Date
    let updatedAt: Date
    
    init(id: String = UUID().uuidString,
         themeName: TravelTheme,
         image: String = "",
         items: [Item] = [],
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.themeName = themeName
        self.image = image
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// 여행 테마 열거형
enum TravelTheme: String, Codable, CaseIterable {

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
        case .mountain: return "산"
        case .camping: return "캠핑"
        case .waterSports: return "수상 스포츠"
        case .cycling: return "사이클링"
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


// 아이템 카테고리 열거형
enum ItemCategory: String, Codable, CaseIterable {
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


// 준비물 아이템 구조체
struct Item: Identifiable, Codable {
    let id: String
    let name: String
    let category: ItemCategory
    let isEssential: Bool
    
    init(id: String = UUID().uuidString, name: String, category: ItemCategory, isEssential: Bool = true) {
        self.id = id
        self.name = name
        self.category = category
        self.isEssential = isEssential
    }
}



// 예시 아이템 데이터
extension Item {
    static let shoppingItems: [Item] = [
        Item(name: "쇼핑백", category: .essentials, isEssential: false),
        Item(name: "신용카드", category: .documents, isEssential: true),
        Item(name: "여행용 소형 가방", category: .essentials, isEssential: true),
        Item(name: "비상금", category: .essentials, isEssential: true)
    ]
    
    static let waterSportsItems: [Item] = [
        Item(name: "수영복", category: .clothing, isEssential: true),
        Item(name: "비치타올", category: .essentials, isEssential: true),
        Item(name: "선글라스", category: .essentials, isEssential: false),
        Item(name: "선크림", category: .toiletries, isEssential: true),
        Item(name: "비치샌들", category: .clothing, isEssential: true),
        Item(name: "방수 가방", category: .essentials, isEssential: false),
        Item(name: "물병", category: .essentials, isEssential: true),
        Item(name: "수상카메라", category: .electronics, isEssential: false)
    ]
    
    static let campingItems: [Item] = [
        Item(name: "텐트", category: .essentials, isEssential: true),
        Item(name: "침낭", category: .essentials, isEssential: true),
        Item(name: "랜턴", category: .electronics, isEssential: true),
        Item(name: "캠핑 의자", category: .essentials, isEssential: false),
        Item(name: "취사도구", category: .essentials, isEssential: true),
        Item(name: "보온 재킷", category: .clothing, isEssential: true),
        Item(name: "방충제", category: .medicines, isEssential: true),
        Item(name: "구급상자", category: .medicines, isEssential: true),
        Item(name: "식수", category: .essentials, isEssential: true)
    ]
    
    static let skiingItems: [Item] = [
        Item(name: "스키복", category: .clothing, isEssential: true),
        Item(name: "스키/보드", category: .essentials, isEssential: false),
        Item(name: "고글", category: .essentials, isEssential: true),
        Item(name: "방한장갑", category: .clothing, isEssential: true),
        Item(name: "보온내의", category: .clothing, isEssential: true),
        Item(name: "목도리", category: .clothing, isEssential: false),
        Item(name: "귀마개", category: .clothing, isEssential: false),
        Item(name: "선크림", category: .toiletries, isEssential: true),
        Item(name: "립밤", category: .toiletries, isEssential: true)
    ]
}

// 예시 테마 템플릿 데이터
extension ThemeTemplate {
    
    static let examples: [ThemeTemplate] = [
        ThemeTemplate(id: "theme1", themeName: .waterSports, image: "waterSports", items: Item.campingItems),
        ThemeTemplate(id: "theme2", themeName: .cycling, image: "cycling", items: Item.skiingItems),
        ThemeTemplate(id: "theme3", themeName: .camping, image: "camping", items: Item.shoppingItems),
        
        ThemeTemplate(id: "theme4", themeName: .picnic, image: "picnic", items: Item.waterSportsItems),
        ThemeTemplate(id: "theme5", themeName: .mountain, image: "mountain", items: Item.waterSportsItems),
        ThemeTemplate(id: "theme6", themeName: .skiing, image: "skiing", items: Item.waterSportsItems),
        
        ThemeTemplate(id: "theme7", themeName: .fishing, image: "fishing", items: Item.waterSportsItems),
        ThemeTemplate(id: "theme8", themeName: .shopping, image: "shopping", items: Item.waterSportsItems),
        ThemeTemplate(id: "theme9", themeName: .themepark, image: "themepark", items: Item.waterSportsItems),
    ]
    
    static func templateFor(theme: TravelTheme) -> ThemeTemplate {
        return examples.first(where: { $0.themeName == theme }) ??
               ThemeTemplate(themeName: theme, image: theme.imageUrl)
    }
}
