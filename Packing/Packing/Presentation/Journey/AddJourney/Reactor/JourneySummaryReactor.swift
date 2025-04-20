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
    }
    
    enum Mutation {
        case setTitle(String)
        case setIsPrivate(Bool)
        case setIsCreating(Bool)
        case setError(Error?)
        case setCreatedJourney(Journey?)
        case complete
    }
    
    struct State {
        var journeyModel: JourneyCreationModel
        var title: String
        var isPrivate: Bool
        var isCreating: Bool
        var createdJourney: Journey?
        var error: Error?
        var shouldComplete: Bool
        
        // 표시용 프로퍼티
        var transportTypeText: String {
            return journeyModel.transportType?.displayName ?? ""
        }
        
        var themeText: String {
            return journeyModel.theme?.displayName ?? ""
        }
        
        var originText: String {
            return journeyModel.origin
        }
        
        var destinationText: String {
            return journeyModel.destination
        }
        
        var dateRangeText: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            
            guard let start = journeyModel.startDate, let end = journeyModel.endDate else {
                return "날짜 미설정"
            }
            
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
    
    let initialState: State
    let parentReactor: CreateJourneyReactor
    
    init(parentReactor: CreateJourneyReactor) {
        self.parentReactor = parentReactor
        let model = parentReactor.currentState.journeyModel
        
        // 제목이 비어있다면 기본 제목 설정
        let defaultTitle = model.title.isEmpty ? "\(model.destination) 여행" : model.title
        
        self.initialState = State(
            journeyModel: model,
            title: defaultTitle,
            isPrivate: model.isPrivate,
            isCreating: false,
            createdJourney: nil,
            error: nil,
            shouldComplete: false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setTitle(let title):
            parentReactor.action.onNext(.setTitle(title))
            return .just(.setTitle(title))
            
        case .setIsPrivate(let isPrivate):
            parentReactor.action.onNext(.setIsPrivate(isPrivate))
            return .just(.setIsPrivate(isPrivate))
            
        case .createJourney:
            // 최종 여행 생성
            parentReactor.action.onNext(.createJourney)
            
            // 부모 리액터의 상태를 구독하여 생성 결과 모니터링
            return parentReactor.state.flatMap { state -> Observable<Mutation> in
                if let error = state.error {
                    return .just(.setError(error))
                }
                
                if let journey = state.createdJourney {
                    return Observable.concat([
                        .just(.setCreatedJourney(journey)),
                        .just(.complete)
                    ])
                }
                
                return .just(.setIsCreating(state.isCreatingJourney))
            }
            
        case .invite:
            // 초대 로직 (실제 구현은 별도로 필요)
            return .empty()
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
        }
        
        return newState
    }
}
