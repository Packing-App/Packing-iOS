//
//  JourneyDateSelectionReactor.swift
//  Packing
//
//  Created by 이융의 on 4/20/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class JourneyDateSelectionReactor: Reactor {
    enum Action {
        case setOrigin(String)
        case setDestination(String)
        case setStartDate(Date)
        case setEndDate(Date)
        case setDates(start: Date, end: Date)
        case next
    }
    
    enum Mutation {
        case setOrigin(String)
        case setDestination(String)
        case setStartDate(Date)
        case setEndDate(Date)
        case setDates(start: Date, end: Date)
        case validateForm
        case proceed
    }
    
    struct State {
        var journeyModel: JourneyCreationModel
        var origin: String
        var destination: String
        var startDate: Date?
        var endDate: Date?
        var canProceed: Bool
        var shouldProceed: Bool
        var errorMessage: String?
    }
    
    let initialState: State
    let parentReactor: CreateJourneyReactor
    
    init(parentReactor: CreateJourneyReactor) {
        self.parentReactor = parentReactor
        let model = parentReactor.currentState.journeyModel
        
        self.initialState = State(
            journeyModel: model,
            origin: model.origin,
            destination: model.destination,
            startDate: model.startDate,
            endDate: model.endDate,
            canProceed: model.canProceedFromDate(),
            shouldProceed: false,
            errorMessage: nil
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setOrigin(let origin):
            parentReactor.action.onNext(.setOrigin(origin))
            return Observable.concat([
                .just(.setOrigin(origin)),
                .just(.validateForm)
            ])
            
        case .setDestination(let destination):
            parentReactor.action.onNext(.setDestination(destination))
            return Observable.concat([
                .just(.setDestination(destination)),
                .just(.validateForm)
            ])
            
        case .setStartDate(let date):
            parentReactor.action.onNext(.setDates(start: date, end: currentState.endDate ?? date))
            return Observable.concat([
                .just(.setStartDate(date)),
                .just(.validateForm)
            ])
            
        case .setEndDate(let date):
            parentReactor.action.onNext(.setDates(start: currentState.startDate ?? date, end: date))
            return Observable.concat([
                .just(.setEndDate(date)),
                .just(.validateForm)
            ])
            
        case .setDates(let start, let end):
            parentReactor.action.onNext(.setDates(start: start, end: end))
            return Observable.concat([
                .just(.setDates(start: start, end: end)),
                .just(.validateForm)
            ])
            
        case .next:
            if currentState.canProceed {
                return .just(.proceed)
            } else {
                // 폼 유효성 검사 다시 실행
                return .just(.validateForm)
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setOrigin(let origin):
            newState.origin = origin
            
        case .setDestination(let destination):
            newState.destination = destination
            
        case .setStartDate(let date):
            newState.startDate = date
            
        case .setEndDate(let date):
            newState.endDate = date
            
        case .setDates(let start, let end):
            newState.startDate = start
            newState.endDate = end
            
        case .validateForm:
            // 폼 유효성 검사
            var errorMessage: String? = nil
            
            if newState.origin.isEmpty {
                errorMessage = "출발지를 입력해주세요"
            } else if newState.destination.isEmpty {
                errorMessage = "도착지를 입력해주세요"
            } else if newState.startDate == nil {
                errorMessage = "출발 날짜를 선택해주세요"
            } else if newState.endDate == nil {
                errorMessage = "도착 날짜를 선택해주세요"
            } else if let start = newState.startDate, let end = newState.endDate, end < start {
                errorMessage = "도착 날짜는 출발 날짜 이후여야 합니다"
            }
            
            newState.errorMessage = errorMessage
            newState.canProceed = errorMessage == nil
            
        case .proceed:
            newState.shouldProceed = true
        }
        
        return newState
    }
}
