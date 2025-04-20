//
//  HomeViewReactor.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class HomeViewReactor: Reactor {
    enum Action {
        case viewDidLoad
        case refreshJourneys
        case selectJourney(Journey)
        case addNewJourney
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setJourneys([Journey])
        case setError(NetworkError?)
    }
    
    struct State {
        var isLoading: Bool = false
        var journeys: [Journey] = []
        var error: NetworkError? = nil
        var themeTemplates: [ThemeTemplate] = ThemeTemplate.examples
    }
    
    let initialState: State
    private let journeyService: JourneyServiceProtocol
    
    init(journeyService: JourneyServiceProtocol = JourneyService()) {
        self.initialState = State()
        self.journeyService = journeyService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad, .refreshJourneys:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                loadJourneys(),
                Observable.just(.setLoading(false))
            ])
        case .selectJourney, .addNewJourney:
            return Observable.empty()   // view controller 에서 처리
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setJourneys(journeys):
            newState.journeys = journeys
            newState.error = nil
            
        case let .setError(error):
            newState.error = error
        }
        return newState
    }
    
    private func loadJourneys() -> Observable<Mutation> {
        return journeyService.getJourneys()
            .map { Mutation.setJourneys($0) }
            .catch { error in
                if let networkError = error as? NetworkError {
                    return Observable.concat([
                        Observable.just(Mutation.setError(networkError)),
                        Observable.just(Mutation.setJourneys([]))
                    ])
                } else {
                    let generalError = NetworkError.unknown
                    return Observable.concat([
                        Observable.just(Mutation.setError(generalError)),
                        Observable.just(Mutation.setJourneys([]))
                    ])
                }
            }
    }
}
