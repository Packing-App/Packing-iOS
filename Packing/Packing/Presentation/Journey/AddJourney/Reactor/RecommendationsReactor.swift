//
//  RecommendationsReactor.swift
//  Packing
//
//  Created on 4/23/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class RecommendationsReactor: Reactor {
    enum Action {
        case toggleItem(itemName: String)
        case updateItemCount(itemName: String, count: Int)
        case addSelectedItems
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoadingMessage(String)
        case setRecommendations(RecommendationResponse)
        case toggleItem(itemName: String)
        case updateItemCount(itemName: String, count: Int)
        case setProcessingAddItems(Bool)
        case setAddItemsResult(APIResponse<[PackingItem]>)
        case setError(Error)
    }
    
    struct State {
        var isLoading: Bool = true
        var loadingMessage: String = ""
        var categories: [String: RecommendationCategory] = [:]
        var journeyInfo: Journey?
        var selectedItems: [String: Int] = [:]  // [아이템이름: 개수]
        var isProcessingAddItems: Bool = false
        var addItemsResult: APIResponse<[PackingItem]>?
        var error: Error?
    }
    
    let initialState: State
    private let journeyService: JourneyServiceProtocol
    private let packingItemsService: PackingItemServiceProtocol
    private let journey: Journey
    private let disposeBag = DisposeBag()
    
    init(journeyService: JourneyServiceProtocol, packingItemService: PackingItemServiceProtocol, journey: Journey) {
        self.journeyService = journeyService
        self.packingItemsService = packingItemService
        self.journey = journey
        self.initialState = State(loadingMessage: "잠시만 기다려주세요.\n\(journey.destination)을 가는 여행자님에게\n꼭 필요한 준비물을 추천해드릴게요.")
    }
    
    // 초기 상태 설정 후 뷰가 바인딩 되면 호출됨
    func fetchRecommendations() -> Observable<Mutation> {
        // 2초 동안 로딩 메시지 표시 후 API 호출
        return Observable.concat([
            Observable<Mutation>.just(.setLoading(true))
                .delay(.seconds(2), scheduler: MainScheduler.instance),
            
            journeyService.getRecommendations(journeyId: journey.id)
                .map { Mutation.setRecommendations($0) }
                .catch { error in
                    print(#fileID, #function, #line, "- ")
                    print("여행 추천 준비물 불러오기 실패: \(error.localizedDescription)")
                    return Observable.just(Mutation.setError(error))
                },
            
            Observable.just(Mutation.setLoading(false))
        ])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .toggleItem(let itemName):
            return Observable.just(Mutation.toggleItem(itemName: itemName))
        case .updateItemCount(let itemName, let count):
            return Observable.just(Mutation.updateItemCount(itemName: itemName, count: count))
        case .addSelectedItems:
            guard !currentState.selectedItems.isEmpty else { return .empty() }
            let selectedRecommendedItems = createSelectedRecommendedItems()
            
            return Observable.concat([
                Observable.just(Mutation.setProcessingAddItems(true)),
                
                packingItemsService.createSelectedRecommendedItems(
                    journeyId: journey.id,
                    selectedItems: selectedRecommendedItems,
                    mergeDuplicates: true
                )
                .map { Mutation.setAddItemsResult($0) }
                .catch { error in return Observable.just(Mutation.setError(error)) },
                
                Observable.just(Mutation.setProcessingAddItems(false))
            ])
            
        }
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        // 초기화 시 한 번만 API 호출
        // This method is called once after the state stream is created.
        let initialMutation = fetchRecommendations()
        return Observable.merge(mutation, initialMutation)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setLoadingMessage(let message):
            newState.loadingMessage = message
            
        case .setRecommendations(let response):
            newState.categories = response.categories
            newState.journeyInfo = response.journey
            
            // 초기 개수 설정
            response.categories.forEach { categoryKey, category in
                category.items.forEach { item in
                    // 기본값으로 선택하지 않음 (개수 0으로 설정!)
                    newState.selectedItems[item.name] = 0
                }
            }
            
        case .toggleItem(let itemName):
            if let currentCount = newState.selectedItems[itemName], currentCount > 0 {
                // 이미 선택한 경우 선택 해제 (0으로 설정)
                newState.selectedItems[itemName] = 0
            } else {
                // 선택되지 않은 경우 선택 (기본값 1 또는 API의 count 사용)
                let count = getDefaultCountForItem(itemName, in: newState.categories) ?? 1
                newState.selectedItems[itemName] = count
            }
            
        case .updateItemCount(let itemName, let count):
            if count <= 0 {
                // 0 이하로 내려가면 선택 해제로 처리
                newState.selectedItems[itemName] = 0
            } else {
                newState.selectedItems[itemName] = count
            }
            
        case .setProcessingAddItems(let isProcessing):
            newState.isProcessingAddItems = isProcessing
            
        case .setAddItemsResult(let result):
            newState.addItemsResult = result
            
        case .setError(let error):
            newState.error = error
            newState.isLoading = false
            newState.isProcessingAddItems = false
        }
        
        return newState
    }
    
    // 선택된 준비물들을 SelectedRecommendedItem 배열로 변환
    private func createSelectedRecommendedItems() -> [SelectedRecommendedItem] {
        var selectedItems: [SelectedRecommendedItem] = []
        
        for (categoryKey, category) in currentState.categories {
            for item in category.items {
                if let count = currentState.selectedItems[item.name], count > 0 {
                    selectedItems.append(
                        SelectedRecommendedItem(
                            name: item.name,
                            category: categoryKey,
                            count: count
                        )
                    )
                }
            }
        }
        return selectedItems
    }
    
    private func getDefaultCountForItem(_ itemName: String, in categories: [String: RecommendationCategory]) -> Int? {
        for (_, category) in categories {
            if let item = category.items.first(where: { $0.name == itemName }) {
                return item.count
            }
        }
        return nil
    }
}
