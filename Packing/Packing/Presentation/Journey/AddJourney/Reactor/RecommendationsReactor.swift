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
    // MARK: - Action
    enum Action {
        case toggleItem(itemName: String)
        case updateItemCount(itemName: String, count: Int)
        case addSelectedItems
        case selectAllInCategory(category: String, select: Bool)
        case selectAll(select: Bool)
    }
    
    // MARK: - Mutation
    enum Mutation {
        case setLoading(Bool)
        case setLoadingMessage(String)
        case setRecommendations(RecommendationResponse)
        case toggleItem(itemName: String)
        case updateItemCount(itemName: String, count: Int)
        case setProcessingAddItems(Bool)
        case setAddItemsResult(APIResponse<[PackingItem]>)
        case selectAllInCategory(category: String, select: Bool)
        case selectAll(select: Bool)
        case setError(Error)
    }
    
    // MARK: - State
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
    
    // MARK: - Properties
    let initialState: State
    private let journeyService: JourneyServiceProtocol
    private let packingItemsService: PackingItemServiceProtocol
    private let journey: Journey
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    init(journeyService: JourneyServiceProtocol, packingItemService: PackingItemServiceProtocol, journey: Journey) {
        self.journeyService = journeyService
        self.packingItemsService = packingItemService
        self.journey = journey
        self.initialState = State(
            loadingMessage: "잠시만 기다려주세요.\n\(journey.destination)을 가는 여행자님에게\n꼭 필요한 준비물을 추천해드릴게요."
        )
        
        print("RecommendationsReactor initialized for journey: \(journey.id)")
    }
    
    // MARK: - Data Loading
    func fetchRecommendations() -> Observable<Mutation> {
        print("Fetching recommendations for journey: \(journey.id)")
        
        return Observable.concat([
            // Initial loading state
            Observable<Mutation>.just(.setLoading(true)),
            
            // Small delay to show loading message
            Observable<Mutation>.just(.setLoading(true))
                .delay(.seconds(1), scheduler: MainScheduler.instance),
            
            // Fetch recommendations from API
            journeyService.getRecommendations(journeyId: journey.id)
                .do(onNext: { response in
                    print("Successfully fetched \(response.categories.count) categories with recommendations")
                })
                .map { Mutation.setRecommendations($0) }
                .catch { error in
                    print("Failed to fetch recommendations: \(error.localizedDescription)")
                    return Observable.just(Mutation.setError(error))
                },
            
            // Complete loading
            Observable.just(Mutation.setLoading(false))
        ])
    }
    
    // MARK: - Action Processing
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .toggleItem(let itemName):
            print("Action: Toggle item: \(itemName)")
            return Observable.just(Mutation.toggleItem(itemName: itemName))
            
        case .updateItemCount(let itemName, let count):
            print("Action: Update item count: \(itemName) to \(count)")
            return Observable.just(Mutation.updateItemCount(itemName: itemName, count: count))
            
        case .addSelectedItems:
            print("Action: Add selected items")
            return handleAddSelectedItemsAction()
            
        case .selectAllInCategory(let category, let select):
            print("Action: Select all in category: \(category), select: \(select)")
            return Observable.just(Mutation.selectAllInCategory(category: category, select: select))
            
        case .selectAll(let select):
            print("Action: Select all: \(select)")
            return Observable.just(Mutation.selectAll(select: select))
        }
    }
    
    private func handleAddSelectedItemsAction() -> Observable<Mutation> {
        // Get selected items
        let selectedItems = createSelectedRecommendedItems()
        
        // If nothing selected, return empty observable
        guard !selectedItems.isEmpty else {
            print("No items selected, not proceeding with add")
            return .empty()
        }
        
        print("Adding \(selectedItems.count) selected items")
        
        return Observable.concat([
            // Start processing
            Observable.just(Mutation.setProcessingAddItems(true)),
            
            // API call to create items
            packingItemsService.createSelectedRecommendedItems(
                journeyId: journey.id,
                selectedItems: selectedItems,
                mergeDuplicates: true
            )
            .do(onNext: { response in
                print("Successfully added \(response.data?.count ?? 0) items")
            })
            .map { Mutation.setAddItemsResult($0) }
            .catch { error in
                print("Error adding items: \(error.localizedDescription)")
                return Observable.just(Mutation.setError(error))
            },
            
            // Complete processing
            Observable.just(Mutation.setProcessingAddItems(false))
        ])
    }
    
    // MARK: - Initial API Call
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        // Fetch recommendations when reactor is initialized
        let initialMutation = fetchRecommendations()
        return Observable.merge(mutation, initialMutation)
    }
    
    // MARK: - State Reduction
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setLoadingMessage(let message):
            newState.loadingMessage = message
            
        case .setRecommendations(let response):
            print("Reducing: Set recommendations with \(response.categories.count) categories")
            newState.categories = response.categories
            newState.journeyInfo = response.journey
            
            // Initialize all items with count 0 (unselected)
            response.categories.forEach { categoryKey, category in
                category.items.forEach { item in
                    newState.selectedItems[item.name] = 0
                }
            }
            
        case .toggleItem(let itemName):
            if let currentCount = newState.selectedItems[itemName], currentCount > 0 {
                // Item is currently selected, deselect it
                print("Reducing: Deselecting item: \(itemName)")
                newState.selectedItems[itemName] = 0
            } else {
                // Item is not selected, select it with default count
                let count = getDefaultCountForItem(itemName, in: newState.categories) ?? 1
                print("Reducing: Selecting item: \(itemName) with count: \(count)")
                newState.selectedItems[itemName] = count
            }
            
        case .updateItemCount(let itemName, let count):
            print("Reducing: Updating count for \(itemName) to \(count)")
            if count <= 0 {
                // Invalid count, deselect item
                newState.selectedItems[itemName] = 0
            } else {
                // Update count
                newState.selectedItems[itemName] = count
            }
            
        case .setProcessingAddItems(let isProcessing):
            newState.isProcessingAddItems = isProcessing
            
        case .setAddItemsResult(let result):
            newState.addItemsResult = result
            
        case .setError(let error):
            print("Reducing: Setting error: \(error.localizedDescription)")
            newState.error = error
            newState.isLoading = false
            newState.isProcessingAddItems = false
            
        case .selectAllInCategory(let category, let select):
            print("Reducing: Select all in category \(category): \(select)")
            // Get all items in the category
            if let categoryItems = newState.categories[category]?.items {
                for item in categoryItems {
                    if select {
                        // Select item with default count
                        let count = getDefaultCountForItem(item.name, in: newState.categories) ?? 1
                        newState.selectedItems[item.name] = count
                    } else {
                        // Deselect item
                        newState.selectedItems[item.name] = 0
                    }
                }
            }
            
        case .selectAll(let select):
            print("Reducing: Select all: \(select)")
            // Select/deselect all items in all categories
            for (_, category) in newState.categories {
                for item in category.items {
                    if select {
                        // Select with default count
                        let count = getDefaultCountForItem(item.name, in: newState.categories) ?? 1
                        newState.selectedItems[item.name] = count
                    } else {
                        // Deselect
                        newState.selectedItems[item.name] = 0
                    }
                }
            }
        }
        
        return newState
    }
    
    // MARK: - Helper Methods
    // Convert selected items to API model
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
    
    // Get default count for an item from API data
    private func getDefaultCountForItem(_ itemName: String, in categories: [String: RecommendationCategory]) -> Int? {
        for (_, category) in categories {
            if let item = category.items.first(where: { $0.name == itemName }) {
                return item.count
            }
        }
        return nil
    }
}
