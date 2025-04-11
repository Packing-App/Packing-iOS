//
//  Theme.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation

struct TravelThemeTemplate {
    let themeName: String
    let image: String
    
    let items: {
        let name: String
        let category: ItemCategory
        let isEssential: Bool
    }
    
    let createdAt: Date
    let updatedAt: Date
}

