//
//  RecommendationsReactor.swift
//  Packing
//
//  Created on 4/23/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class RecommendationsReactor: Reactor {
    enum Action {
        // 추가 액션이 필요할 경우 정의
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoadingMessage(String)
        case setRecommendations(RecommendationResponse)
        case setError(Error)
    }
    
    struct State {
        var isLoading: Bool = true
        var loadingMessage: String = ""
        var categories: [String: RecommendationCategory] = [:]
        var journeyInfo: Journey?
        var error: Error?
    }
    
    let initialState: State
    private let journeyService: JourneyServiceProtocol
    private let journey: Journey
    private let disposeBag = DisposeBag()
    
    init(journeyService: JourneyServiceProtocol, journey: Journey) {
        self.journeyService = journeyService
        self.journey = journey
        self.initialState = State(loadingMessage: "잠시만 기다려주세요.\n\(journey.destination)을 가는 여행자님에게\n꼭 필요한 준비물을 추천해드릴게요.")
    }
    
    // 초기 상태 설정 후 뷰가 바인딩 되면 호출됨
    func fetchRecommendations() -> Observable<Mutation> {
        // 2초 동안 로딩 메시지 표시 후 API 호출
        return Observable.concat([
            Observable<Mutation>.just(.setLoading(true))
                .delay(.seconds(2), scheduler: MainScheduler.instance),
            
            journeyService.getRecommendations(journeyId: journey.id)
                .map { Mutation.setRecommendations($0) }
                .catch { error in
                    print(#fileID, #function, #line, "- ")
                    print("여행 추천 준비물 불러오기 실패: \(error.localizedDescription)")
                    return Observable.just(Mutation.setError(error))
                },
            
            Observable.just(Mutation.setLoading(false))
        ])
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        // Action이 없을 때는 empty 반환
        return .empty()
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        // 초기화 시 한 번만 API 호출
        let initialMutation = fetchRecommendations()
        return Observable.merge(mutation, initialMutation)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setLoadingMessage(let message):
            newState.loadingMessage = message
            
        case .setRecommendations(let response):
            newState.categories = response.categories
            newState.journeyInfo = response.journey
            
        case .setError(let error):
            newState.error = error
            newState.isLoading = false
        }
        
        return newState
    }
}
