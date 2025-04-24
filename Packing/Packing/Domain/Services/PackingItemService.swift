//
//  PackingItemService.swift
//  Packing
//
//  Created by 이융의 on 4/24/25.
//

import Foundation

// MARK: - PackingItemService Protocol
protocol PackingItemServiceProtocol {
    /*
     
     // 여행별 준비물 목록 조회
     case getPackingItemsByJourney(journeyId: String)
     
     // 준비물 생성
     case createPackingItem(
         journeyId: String,
         name: String,
         count: Int,
         category: ItemCategory,
         isShared: Bool,
         assignedTo: String?
     )
     
     // 준비물 일괄 생성 (테마 템플릿에서 가져오기)
     case createBulkPackingItems(
         journeyId: String,
         templateName: String,
         selectedItems: [String],
         mergeDuplicates: Bool
     )
     
     // 추천 준비물에서 선택한 준비물들을 일괄 등록
     case createSelectedRecommendedItems(
         journeyId: String,
         selectedItems: [SelectedRecommendedItem],
         mergeDuplicates: Bool
     )
     
     // 준비물 업데이트
     case updatePackingItem(
         id: String,
         name: String?,
         count: Int?,
         category: ItemCategory?,
         isShared: Bool?,
         assignedTo: String?
     )
     
     // 준비물 체크 상태 토글
     case togglePackingItem(id: String)
     
     // 준비물 삭제
     case deletePackingItem(id: String)
     
     // 카테고리별 준비물 조회
     case getPackingItemsByCategory(journeyId: String)
     
     // 테마별 준비물 템플릿 목록 조회
     case getThemeTemplates
     
     // 특정 테마의 준비물 템플릿 조회
     case getThemeTemplateByName(themeName: String)
     
     */
}

// MARK: - LocationService Implementation
class PackingItemService: PackingItemServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
}
