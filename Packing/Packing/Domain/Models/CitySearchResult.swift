//
//  CitySearchResult.swift
//  Packing
//
//  Created by 이융의 on 4/22/25.
//

import Foundation

// MARK: - Location 응답 모델
struct CitySearchResult: Codable {
    let korName: String
    let engName: String
    let countryCode: String
}

struct CityTranslation: Codable {
    let korName: String
    let engName: String
    let countryCode: String
}
