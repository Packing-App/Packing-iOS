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
        case selectTheme(TravelTheme)
//        case toggleTheme(TravelTheme)
        case next
        case viewDidAppear
    }
    
    enum Mutation {
        case setTheme(TravelTheme)
        case validateForm
        case proceed
        case resetProceedState
    }
    
    struct State {
        var selectedTheme: TravelTheme?
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
            selectedTheme: model.theme,
            canProceed: model.theme != nil,
            shouldProceed: false,
            themeTemplates: ThemeListModel.examples
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectTheme(let theme):
            coordinator.updateTheme(theme)
            return Observable.concat([
                .just(.setTheme(theme)),
                .just(.validateForm)
            ])
            
//        case .toggleTheme(let theme):
//            // 이미 선택된 테마면 선택 해제, 아니면 선택
//            if currentState.selectedTheme == theme {
//                parentReactor.action.onNext(.setTheme(theme))
//                return Observable.concat([
//                    .just(.setTheme(theme)),
//                    .just(.validateForm)
//                ])
//            } else {
//                parentReactor.action.onNext(.setTheme(theme))
//                return Observable.concat([
//                    .just(.setTheme(theme)),
//                    .just(.validateForm)
//                ])
//            }
            
        case .next:
            if currentState.canProceed {
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
        case .setTheme(let theme):
            newState.selectedTheme = theme
            
        case .validateForm:
            newState.canProceed = newState.selectedTheme != nil
            
        case .proceed:
            newState.shouldProceed = true
            
        case .resetProceedState:
            newState.shouldProceed = false
        }
        
        return newState
    }
}
