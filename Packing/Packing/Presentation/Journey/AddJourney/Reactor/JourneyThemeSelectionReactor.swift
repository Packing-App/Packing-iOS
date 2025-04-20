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
        case toggleTheme(TravelTheme)
        case next
    }
    
    enum Mutation {
        case setTheme(TravelTheme)
        case validateForm
        case proceed
    }
    
    struct State {
        var journeyModel: JourneyCreationModel
        var selectedTheme: TravelTheme?
        var canProceed: Bool
        var shouldProceed: Bool
        var themeTemplates: [ThemeTemplate]
    }
    
    let initialState: State
    let parentReactor: CreateJourneyReactor
    
    init(parentReactor: CreateJourneyReactor) {
        self.parentReactor = parentReactor
        let model = parentReactor.currentState.journeyModel
        
        self.initialState = State(
            journeyModel: model,
            selectedTheme: model.theme,
            canProceed: model.theme != nil,
            shouldProceed: false,
            themeTemplates: ThemeTemplate.examples
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectTheme(let theme):
            parentReactor.action.onNext(.setTheme(theme))
            return Observable.concat([
                .just(.setTheme(theme)),
                .just(.validateForm)
            ])
            
        case .toggleTheme(let theme):
            // 이미 선택된 테마면 선택 해제, 아니면 선택
            if currentState.selectedTheme == theme {
                parentReactor.action.onNext(.setTheme(theme))
                return Observable.concat([
                    .just(.setTheme(theme)),
                    .just(.validateForm)
                ])
            } else {
                parentReactor.action.onNext(.setTheme(theme))
                return Observable.concat([
                    .just(.setTheme(theme)),
                    .just(.validateForm)
                ])
            }
            
        case .next:
            if currentState.canProceed {
                return .just(.proceed)
            } else {
                return .just(.validateForm)
            }
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
        }
        
        return newState
    }
}
