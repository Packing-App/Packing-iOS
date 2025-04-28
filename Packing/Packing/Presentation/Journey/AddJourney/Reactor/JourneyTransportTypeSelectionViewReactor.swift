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
        case viewDidAppear
    }
    
    // State 변화를 위한 Mutation 정의
    enum Mutation {
        case setTransportType(TransportType)
        case proceed
        case resetProceedState
    }
    
    // 화면의 상태를 나타내는 State 정의
    struct State {
        var selectedTransportType: TransportType?
        var canProceed: Bool
        var shouldProceed: Bool
    }
    
    let initialState: State
    let coordinator: JourneyCreationCoordinator
    
    init(coordinator: JourneyCreationCoordinator) {
        self.coordinator = coordinator
        let model = coordinator.getJourneyModel()
        
        self.initialState = State(
            selectedTransportType: model.transportType,
            canProceed: model.transportType != nil,
            shouldProceed: false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectTransportType(let type):
            // 상위 리액터에 변경 사항 전달
            coordinator.updateTransportType(type)
            return .just(.setTransportType(type))
                        
        case .next:
            coordinator.moveToNextStep()
            return .just(.proceed)
            
        case .skip:
            // 기본값 설정 후 다음 단계로 진행
            let defaultType = TransportType.other
            coordinator.updateTransportType(defaultType)
            coordinator.moveToNextStep()
            return Observable.concat([
                .just(.setTransportType(defaultType)),
                .just(.proceed)
            ])
            
        case .viewDidAppear:
            return .just(.resetProceedState)
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
            
        case .resetProceedState:
            newState.shouldProceed = false
        }
        
        return newState
    }
}
