//
//  PackingItemService.swift
//  Packing
//
//  Created by 이융의 on 4/24/25.
//

import Foundation
import RxSwift

// MARK: - PackingItemService Protocol
protocol PackingItemServiceProtocol {
    func getPackingItemsByJourney(journeyId: String) -> Observable<APIResponse<[PackingItem]>>
    
    func createPackingItem(
        journeyId: String,
        name: String,
        count: Int,
        category: ItemCategory,
        isShared: Bool,
        assignedTo: String?
    ) -> Observable<APIResponse<PackingItem>>
    
    // 준비물 일괄 생성 (테마 템플릿에서 가져오기)
    func createBulkPackingItems(
        journeyId: String,
        templateName: String,
        selectedItems: [String],
        mergeDuplicates: Bool
    ) -> Observable<APIResponse<[PackingItem]>>
    
    // 추천 준비물에서 선택한 준비물들을 일괄 등록
    func createSelectedRecommendedItems(
        journeyId: String,
        selectedItems: [SelectedRecommendedItem],
        mergeDuplicates: Bool
    ) -> Observable<APIResponse<[PackingItem]>>
    
    // 준비물 업데이트
    func updatePackingItem(
        id: String,
        name: String?,
        count: Int?,
        category: ItemCategory?,
        isShared: Bool?,
        assignedTo: String?
    ) -> Observable<APIResponse<PackingItem>>
    
    // 준비물 체크 상태 토글
    func togglePackingItem(id: String) -> Observable<APIResponse<PackingItem>>
    
    // 준비물 삭제
    func deletePackingItem(id: String) -> Observable<APIResponse<Bool>>
    
    // 카테고리별 준비물 조회
    func getPackingItemsByCategory(journeyId: String) -> Observable<APIResponse<[String: [PackingItem]]>>
    
    // 테마별 준비물 템플릿 목록 조회
    func getThemeTemplates() -> Observable<APIResponse<[ThemeTemplate]>>
    
    // 특정 테마의 준비물 템플릿 조회
    func getThemeTemplateByName(themeName: String) -> Observable<APIResponse<ThemeTemplate>>
}

// MARK: - LocationService Implementation

// MARK: - PackingItemService Implementation
class PackingItemService: PackingItemServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    // 여행별 준비물 목록 조회
    func getPackingItemsByJourney(journeyId: String) -> Observable<APIResponse<[PackingItem]>> {
        let endpoint = APIEndpoint.getPackingItemsByJourney(journeyId: journeyId)
        return apiClient.requestWithDateDecoding(endpoint)
    }
    
    // 준비물 생성
    func createPackingItem(
        journeyId: String,
        name: String,
        count: Int,
        category: ItemCategory,
        isShared: Bool,
        assignedTo: String?
    ) -> Observable<APIResponse<PackingItem>> {
        let endpoint = APIEndpoint.createPackingItem(
            journeyId: journeyId,
            name: name,
            count: count,
            category: category,
            isShared: isShared,
            assignedTo: assignedTo
        )
        return apiClient.requestWithDateDecoding(endpoint)
    }
    
    // 준비물 일괄 생성 (테마 템플릿에서 가져오기)
    func createBulkPackingItems(
        journeyId: String,
        templateName: String,
        selectedItems: [String],
        mergeDuplicates: Bool
    ) -> Observable<APIResponse<[PackingItem]>> {
        let endpoint = APIEndpoint.createBulkPackingItems(
            journeyId: journeyId,
            templateName: templateName,
            selectedItems: selectedItems,
            mergeDuplicates: mergeDuplicates
        )
        return apiClient.requestWithDateDecoding(endpoint)
    }
    
    // 추천 준비물에서 선택한 준비물들을 일괄 등록
    func createSelectedRecommendedItems(
        journeyId: String,
        selectedItems: [SelectedRecommendedItem],
        mergeDuplicates: Bool
    ) -> Observable<APIResponse<[PackingItem]>> {
        let endpoint = APIEndpoint.createSelectedRecommendedItems(
            journeyId: journeyId,
            selectedItems: selectedItems,
            mergeDuplicates: mergeDuplicates
        )
        return apiClient.requestWithDateDecoding(endpoint)
    }
    
    // 준비물 업데이트
    func updatePackingItem(
        id: String,
        name: String?,
        count: Int?,
        category: ItemCategory?,
        isShared: Bool?,
        assignedTo: String?
    ) -> Observable<APIResponse<PackingItem>> {
        let endpoint = APIEndpoint.updatePackingItem(
            id: id,
            name: name,
            count: count,
            category: category,
            isShared: isShared,
            assignedTo: assignedTo
        )
        return apiClient.requestWithDateDecoding(endpoint)
    }
    
    // 준비물 체크 상태 토글
    func togglePackingItem(id: String) -> Observable<APIResponse<PackingItem>> {
        let endpoint = APIEndpoint.togglePackingItem(id: id)
        return apiClient.requestWithDateDecoding(endpoint)
    }
    
    // 준비물 삭제
    func deletePackingItem(id: String) -> Observable<APIResponse<Bool>> {
        let endpoint = APIEndpoint.deletePackingItem(id: id)
        return apiClient.request(endpoint)
    }
    
    // 카테고리별 준비물 조회
    func getPackingItemsByCategory(journeyId: String) -> Observable<APIResponse<[String: [PackingItem]]>> {
        let endpoint = APIEndpoint.getPackingItemsByCategory(journeyId: journeyId)
        return apiClient.requestWithDateDecoding(endpoint)
    }
    
    // 테마별 준비물 템플릿 목록 조회
    func getThemeTemplates() -> Observable<APIResponse<[ThemeTemplate]>> {
        let endpoint = APIEndpoint.getThemeTemplates
        return apiClient.request(endpoint)
    }
    
    // 특정 테마의 준비물 템플릿 조회
    func getThemeTemplateByName(themeName: String) -> Observable<APIResponse<ThemeTemplate>> {
        let endpoint = APIEndpoint.getThemeTemplateByName(themeName: themeName)
        return apiClient.request(endpoint)
    }
}
