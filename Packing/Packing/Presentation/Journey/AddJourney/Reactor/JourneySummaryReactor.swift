//
//  JourneySummaryReactor.swift
//  Packing
//
//  Created by 이융의 on 4/20/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class JourneySummaryReactor: Reactor {
    enum Action {
        case setTitle(String)
        case setIsPrivate(Bool)
        case createJourney
        case invite
        case viewDidAppear
    }
    
    enum Mutation {
        case setTitle(String)
        case setIsPrivate(Bool)
        case setIsCreating(Bool)
        case setError(Error?)
        case setCreatedJourney(Journey?)
        case complete
        case resetProceedState
    }
    
    struct State {
        var title: String
        var isPrivate: Bool
        var isCreating: Bool
        var createdJourney: Journey?
        var error: Error?
        var shouldComplete: Bool
        
        var transportTypeText: String
        var themeText: String
        var originText: String
        var destinationText: String
        var dateRangeText: String
    }
    
    let initialState: State
    let coordinator: JourneyCreationCoordinator
    
    init(coordinator: JourneyCreationCoordinator) {
        self.coordinator = coordinator
        let model = coordinator.getJourneyModel()
        
        // 제목이 비어있다면 기본 제목 설정
        let defaultTitle = model.title.isEmpty ? "\(model.destination) 여행" : model.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        let dateRangeText: String
        if let start = model.startDate, let end = model.endDate {
            dateRangeText = "\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))"
        } else {
            dateRangeText = "날짜 미설정"
        }
        
        self.initialState = State(
            title: defaultTitle,
            isPrivate: model.isPrivate,
            isCreating: false,
            createdJourney: nil,
            error: nil,
            shouldComplete: false,
            transportTypeText: model.transportType?.displayName ?? "",
            themeText: model.theme?.displayName ?? "",
            originText: model.origin,
            destinationText: model.destination,
            dateRangeText: dateRangeText
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setTitle(let title):
            coordinator.updateTitle(title)
            return .just(.setTitle(title))
            
        case .setIsPrivate(let isPrivate):
            coordinator.updateIsPrivate(isPrivate)
            return .just(.setIsPrivate(isPrivate))
            
        case .createJourney:
            // 생성 상태 모니터링
            let creatingObservable = coordinator.isCreatingJourney()
                .map { Mutation.setIsCreating($0) }
            
            // 오류 모니터링
            let errorObservable = coordinator.getError()
                .map { Mutation.setError($0) }
            
            // 여행 생성 요청 및 결과 모니터링
            let journeyObservable = coordinator.createJourney()
                .flatMap { journey -> Observable<Mutation> in
                    guard journey != nil else {
                        return .empty()
                    }
                    return Observable.concat([
                        .just(Mutation.setCreatedJourney(journey)),
                        .just(Mutation.complete)
                    ])
                }
            
            return Observable.merge(
                creatingObservable,
                errorObservable,
                journeyObservable
            )
            
        case .invite:
            // 초대 기능은 별도 구현 필요
            return .empty()
            
        case .viewDidAppear:
            return .just(.resetProceedState)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTitle(let title):
            newState.title = title
            
        case .setIsPrivate(let isPrivate):
            newState.isPrivate = isPrivate
            
        case .setIsCreating(let isCreating):
            newState.isCreating = isCreating
            
        case .setError(let error):
            newState.error = error
            newState.isCreating = false
            
        case .setCreatedJourney(let journey):
            newState.createdJourney = journey
            newState.isCreating = false
            
        case .complete:
            newState.shouldComplete = true
            
        case .resetProceedState:
            newState.shouldComplete = false
        }
        
        return newState
    }
}
