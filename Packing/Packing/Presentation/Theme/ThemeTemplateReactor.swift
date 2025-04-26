//
//  ThemeTemplateReactor.swift
//  Packing
//
//  Created by 이융의 on 4/26/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class ThemeTemplateReactor: Reactor {
    enum Action {
        case loadTemplate(themeName: TravelTheme)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setTemplate(ThemeTemplate)
        case setError(NetworkError?)
    }
    
    struct State {
        var isLoading: Bool = false
        var template: ThemeTemplate?
        var error: NetworkError?
        var groupedItems: [String: [RecommendedItem]] = [:]
        var categories: [String] = []
    }
    
    let initialState: State
    private let packingItemService: PackingItemServiceProtocol
    
    init(packingItemService: PackingItemServiceProtocol = PackingItemService()) {
        self.initialState = State()
        self.packingItemService = packingItemService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadTemplate(let themeName):
            return Observable.concat([
                Observable.just(.setLoading(true)),
                loadThemeTemplate(themeName: themeName),
                Observable.just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setTemplate(template):
            newState.template = template
            newState.error = nil
            
            // Group items by category
            var groupedItems: [String: [RecommendedItem]] = [:]
            for item in template.items {
                let category = item.category
                if groupedItems[category] == nil {
                    groupedItems[category] = []
                }
                groupedItems[category]?.append(item)
            }
            newState.groupedItems = groupedItems
            newState.categories = Array(groupedItems.keys).sorted {
                if $0 == "essentials" { return true }
                if $1 == "essentials" { return false }
                return $0 < $1
            }
            
        case let .setError(error):
            newState.error = error
        }
        
        return newState
    }
    
    private func loadThemeTemplate(themeName: TravelTheme) -> Observable<Mutation> {
        return packingItemService.getThemeTemplateByName(themeName: themeName.rawValue)
            .map { response in
                guard let template = response.data else {
                    return Mutation.setError(NetworkError.invalidResponse)
                }
                return Mutation.setTemplate(template)
            }
            .catch { error in
                if let networkError = error as? NetworkError {
                    return Observable.just(Mutation.setError(networkError))
                } else {
                    return Observable.just(Mutation.setError(NetworkError.unknown))
                }
            }
    }
}
