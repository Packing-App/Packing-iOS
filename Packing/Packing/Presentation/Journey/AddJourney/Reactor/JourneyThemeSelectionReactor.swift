//
//  JourneyThemeSelectionReactor.swift
//  Packing
//
//  Created by 이융의 on 4/20/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class JourneyThemeSelectionReactor: Reactor {
    enum Action {
        case toggleTheme(TravelTheme)
        case next
        case viewDidAppear
    }
    
    enum Mutation {
        case toggleTheme(TravelTheme)
        case validateForm
        case proceed
        case resetProceedState
    }
    
    struct State {
        var selectedThemes: Set<TravelTheme>
        var canProceed: Bool
        var shouldProceed: Bool
        var themeTemplates: [ThemeListModel]
    }
    
    let initialState: State
    let coordinator: JourneyCreationCoordinator

    init(coordinator: JourneyCreationCoordinator) {
        self.coordinator = coordinator
        let model = coordinator.getJourneyModel()
        
        self.initialState = State(
            selectedThemes: model.themes,
            canProceed: !model.themes.isEmpty,
            shouldProceed: false,
            themeTemplates: ThemeListModel.examples
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .toggleTheme(let theme):
            return Observable.concat([
                .just(.toggleTheme(theme)),
                .just(.validateForm)
            ])
            
        case .next:
            if currentState.canProceed {
                // 선택된 테마들을 coordinator에 전달
                coordinator.updateThemes(currentState.selectedThemes)
                coordinator.moveToNextStep()
                return .just(.proceed)
            } else {
                return .just(.validateForm)
            }
            
        case .viewDidAppear:
            return .just(.resetProceedState)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .toggleTheme(let theme):
            if newState.selectedThemes.contains(theme) {
                newState.selectedThemes.remove(theme)
            } else {
                newState.selectedThemes.insert(theme)
            }
            
        case .validateForm:
            newState.canProceed = !newState.selectedThemes.isEmpty
            
        case .proceed:
            newState.shouldProceed = true
            
        case .resetProceedState:
            newState.shouldProceed = false
        }
        
        return newState
    }
}
