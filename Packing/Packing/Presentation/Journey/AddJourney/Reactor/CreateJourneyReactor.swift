//
//  CreateJourneyReactor.swift
//  Packing
//
//  Created by 이융의 on 4/20/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

// 여행 생성 과정에서 필요한 필드를 담는 모델
struct JourneyCreationModel {
    var transportType: TransportType?
    var themes: Set<TravelTheme> = []
    var origin: String = ""
    var destination: String = ""
    var startDate: Date?
    var endDate: Date?
    var title: String = ""
    var isPrivate: Bool = false
    
    // 다음 단계로 진행할 수 있는지 검증하는 메서드들
    func canProceedFromTransport() -> Bool {
        return transportType != nil
    }
    
    func canProceedFromDate() -> Bool {
        return !origin.isEmpty && !destination.isEmpty && startDate != nil && endDate != nil
    }
    
    func canProceedFromTheme() -> Bool {
        return !themes.isEmpty
    }
    
    func canCreateJourney() -> Bool {
        return transportType != nil &&
               !origin.isEmpty &&
               !destination.isEmpty &&
               startDate != nil &&
               endDate != nil &&
               !themes.isEmpty
    }
}

// 최상위 여행 생성 리액터
class CreateJourneyReactor: Reactor {
    enum Action {
        case setTransportType(TransportType)
        case setOrigin(String)
        case setDestination(String)
        case setDates(start: Date, end: Date)
        case setThemes(Set<TravelTheme>)
        case setTitle(String)
        case setIsPrivate(Bool)
        case createJourney
        case resetModel
    }
    
    enum Mutation {
        case setTransportType(TransportType)
        case setOrigin(String)
        case setDestination(String)
        case setDates(start: Date, end: Date)
        case setThemes(Set<TravelTheme>)
        case setTitle(String)
        case setIsPrivate(Bool)
        case setCreatingJourney(Bool)
        case setError(Error?)
        case setCreatedJourney(Journey?)
        case resetModel
    }
    
    struct State {
        var journeyModel = JourneyCreationModel()
        var isCreatingJourney: Bool = false
        var error: Error? = nil
        var createdJourney: Journey? = nil
    }
    
    let initialState: State
    let journeyService: JourneyServiceProtocol
    
    init(journeyService: JourneyServiceProtocol) {
        self.initialState = State()
        self.journeyService = journeyService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setTransportType(let type):
            return .just(.setTransportType(type))
            
        case .setOrigin(let origin):
            return .just(.setOrigin(origin))
            
        case .setDestination(let destination):
            return .just(.setDestination(destination))
            
        case .setDates(let start, let end):
            return .just(.setDates(start: start, end: end))
            
        case .setThemes(let themes):
            return .just(.setThemes(themes))
            
        case .setTitle(let title):
            return .just(.setTitle(title))
            
        case .setIsPrivate(let isPrivate):
            return .just(.setIsPrivate(isPrivate))
            
        case .createJourney:
            guard currentState.journeyModel.canCreateJourney() else {
                return .just(.setError(NSError(domain: "JourneyCreation", code: 400, userInfo: [NSLocalizedDescriptionKey: "모든 필수 정보를 입력해주세요"])))
            }
            
            let model = currentState.journeyModel
            
            var title: String
            if model.title.isEmpty {
                let languageCode = Locale.current.language.languageCode?.identifier
                title = "\(model.destination) \(languageCode == "ko" ? "여행" : "Trip")"
            } else {
                title = model.title
            }
            
            // 선택된 테마들을 배열로 변환
            let themes = Array(model.themes)
            
            return Observable.concat([
                .just(.setCreatingJourney(true)),
                
                journeyService.createJourney(
                    title: title,
                    transportType: model.transportType!,
                    origin: model.origin,
                    destination: model.destination,
                    startDate: model.startDate!,
                    endDate: model.endDate!,
                    themes: themes,
                    isPrivate: model.isPrivate
                )
                .map { Mutation.setCreatedJourney($0) }
                .catch { error -> Observable<Mutation> in
                    print(#fileID, #function, #line, "- ")
                    print(error.localizedDescription)
                    return .just(.setError(error))
                },
                
                .just(.setCreatingJourney(false))
            ])
            
        case .resetModel: return .just(.resetModel)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTransportType(let type):
            newState.journeyModel.transportType = type
            
        case .setOrigin(let origin):
            newState.journeyModel.origin = origin
            
        case .setDestination(let destination):
            newState.journeyModel.destination = destination
            
        case .setDates(let start, let end):
            newState.journeyModel.startDate = start
            newState.journeyModel.endDate = end
            
        case .setThemes(let themes):
            newState.journeyModel.themes = themes
            
        case .setTitle(let title):
            newState.journeyModel.title = title
            
        case .setIsPrivate(let isPrivate):
            newState.journeyModel.isPrivate = isPrivate
            
        case .setCreatingJourney(let isCreating):
            newState.isCreatingJourney = isCreating
            
        case .setError(let error):
            newState.error = error
            
        case .setCreatedJourney(let journey):
            newState.createdJourney = journey
            
        case .resetModel:
            newState.journeyModel = JourneyCreationModel()
            newState.error = nil
            newState.createdJourney = nil
            newState.isCreatingJourney = false
        }
        
        return newState
    }
}
