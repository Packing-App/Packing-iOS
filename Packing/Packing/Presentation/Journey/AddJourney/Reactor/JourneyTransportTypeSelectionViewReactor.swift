//
//  JourneyTransportTypeSelectionViewReactor.swift
//  Packing
//
//  Created by 이융의 on 4/20/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class JourneyTransportTypeSelectionReactor: Reactor {
    // View에서 받을 수 있는 Action 타입 정의
    enum Action {
        case selectTransportType(TransportType)
        case next
        case skip
    }
    
    // State 변화를 위한 Mutation 정의
    enum Mutation {
        case setTransportType(TransportType)
        case proceed
    }
    
    // 화면의 상태를 나타내는 State 정의
    struct State {
        var journeyModel: JourneyCreationModel
        var selectedTransportType: TransportType?
        var canProceed: Bool
        var shouldProceed: Bool
    }
    
    let initialState: State
    let parentReactor: CreateJourneyReactor
    
    init(parentReactor: CreateJourneyReactor) {
        self.parentReactor = parentReactor
        self.initialState = State(
            journeyModel: parentReactor.currentState.journeyModel,
            selectedTransportType: parentReactor.currentState.journeyModel.transportType,
            canProceed: parentReactor.currentState.journeyModel.transportType != nil,
            shouldProceed: false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectTransportType(let type):
            // 상위 리액터에 변경 사항 전달
            parentReactor.action.onNext(.setTransportType(type))
            return .just(.setTransportType(type))
            
        case .next:
            return .just(.proceed)
            
        case .skip:
            // 기본값 설정 후 다음 단계로 진행
            let defaultType = TransportType.other
            parentReactor.action.onNext(.setTransportType(defaultType))
            return Observable.concat([
                .just(.setTransportType(defaultType)),
                .just(.proceed)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTransportType(let type):
            newState.selectedTransportType = type
            newState.canProceed = true
            
        case .proceed:
            newState.shouldProceed = true
        }
        
        return newState
    }
}
