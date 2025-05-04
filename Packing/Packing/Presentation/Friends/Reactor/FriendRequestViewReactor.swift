//
//  FriendRequestViewReactor.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class FriendRequestsViewReactor: Reactor {
    
    // Action: 사용자 입력
    enum Action {
        case viewDidLoad
        case respondToRequest(id: String, accept: Bool)
    }
    
    // Mutation: 상태 변화를 위한 중간 단계
    enum Mutation {
        case setLoading(Bool)
        case setReceivedRequests([ReceivedFriendRequest])
        case setSentRequests([SentFriendRequest])
        case removeReceivedRequest(id: String)
        case setError(Error?)
        case clearError
    }
    
    // State: 뷰의 상태
    struct State {
        var isLoading: Bool = false
        var receivedRequests: [ReceivedFriendRequest] = []
        var sentRequests: [SentFriendRequest] = []
        var error: Error? = nil
    }
    
    let initialState = State()
    
    private let friendshipService: FriendshipServiceProtocol
    
    // 의존성 주입
    init(friendshipService: FriendshipServiceProtocol = FriendshipService()) {
        self.friendshipService = friendshipService
    }
    
    // Action → Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return loadFriendRequests()
            
        case let .respondToRequest(id, accept):
            return respondToRequest(id: id, accept: accept)
        }
    }
    
    // Mutation → State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setReceivedRequests(let requests):
            newState.receivedRequests = requests
            
        case .setSentRequests(let requests):
            newState.sentRequests = requests
            
        case .removeReceivedRequest(let id):
            newState.receivedRequests.removeAll { $0.id == id }
            
        case .setError(let error):
            newState.error = error
            
        case .clearError:
            newState.error = nil
        }
        
        return newState
    }
    
    // MARK: - 비즈니스 로직 메서드
    
    // 친구 요청 목록 로드
    private func loadFriendRequests() -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            friendshipService.getFriendRequests()
                .flatMap { response -> Observable<Mutation> in
                    return .merge([
                        .just(.setReceivedRequests(response.received)),
                        .just(.setSentRequests(response.sent))
                    ])
                }
                .catch { error -> Observable<Mutation> in
                    return .just(.setError(error))
                },
            .just(.setLoading(false))
        ])
    }
    
    // 친구 요청 응답 (수락/거절)
    private func respondToRequest(id: String, accept: Bool) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            friendshipService.respondToFriendRequest(id: id, accept: accept)
                .flatMap { success -> Observable<Mutation> in
                    if success {
                        return .concat([
                            .just(.removeReceivedRequest(id: id)),
                            .just(.clearError)
                        ])
                    } else {
                        return .just(.setError(NetworkError.serverError("요청 처리에 실패했습니다.")))
                    }
                }
                .catch { error -> Observable<Mutation> in
                    return .just(.setError(error))
                },
            .just(.setLoading(false))
        ])
    }
}
