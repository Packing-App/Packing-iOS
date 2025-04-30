//
//  FriendsViewReactor.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import ReactorKit
import RxSwift
import RxCocoa

final class FriendsViewReactor: Reactor {
    enum ViewMode {
        case friendsList
        case searchResults
    }
    
    // Action: 사용자 입력
    enum Action {
        case viewDidLoad
        case searchFriend(String)
        case clearSearch
        case sendFriendRequest(String)
        case removeFriend(String)
        case navigateToRequestsView
        case inviteFriendToJourney(String, String)
    }
    
    // Mutation: 상태 변화를 위한 중간 단계
    enum Mutation {
        case setLoading(Bool)
        case setFriends([Friend])
        case setSearchResults([FriendSearchResult])
        case setViewMode(ViewMode)
        case setError(Error?)
        case clearError
    }
    
    // State: 뷰의 상태
    struct State {
        var isLoading: Bool = false
        var friends: [Friend] = []
        var searchResults: [FriendSearchResult] = []
        var viewMode: ViewMode = .friendsList
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
            return loadFriends()
            
        case .searchFriend(let query):
            if query.isEmpty {
                return .concat([
                    .just(.setViewMode(.friendsList)),
                    .just(.setSearchResults([]))
                ])
            } else {
                return searchFriends(query: query)
            }
            
        case .clearSearch:
            return .concat([
                .just(.setViewMode(.friendsList)),
                .just(.setSearchResults([]))
            ])
            
        case .sendFriendRequest(let email):
            return sendFriendRequest(email: email)
            
        case .removeFriend(let friendshipId):
            return removeFriend(friendshipId: friendshipId)
            
        case .navigateToRequestsView:
            // 여기서는 상태 변화가 없음 (네비게이션은 뷰컨트롤러에서 처리)
            return .empty()
        case .inviteFriendToJourney(_, _):
            // 여행 초대 기능은 JourneySelectionViewController에서 직접 처리
            // 여기서는 상태 변화가 없음
            return .empty()
        }
    }
    
    // Mutation → State
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setFriends(let friends):
            newState.friends = friends
            
        case .setSearchResults(let results):
            newState.searchResults = results
            
        case .setViewMode(let mode):
            newState.viewMode = mode
            
        case .setError(let error):
            newState.error = error
            
        case .clearError:
            newState.error = nil
        }
        
        return newState
    }
    
    // MARK: - 비즈니스 로직 메서드
    
    // 친구 목록 로드
    private func loadFriends() -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            friendshipService.getFriends()
                .map { Mutation.setFriends($0) }
                .catch { error -> Observable<Mutation> in
                    return .just(.setError(error))
                },
            .just(.setLoading(false))
        ])
    }
    
    // 친구 검색
    private func searchFriends(query: String) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            .just(.setViewMode(.searchResults)),
            friendshipService.searchFriendByEmail(email: query)
                .map { Mutation.setSearchResults($0) }
                .catch { error -> Observable<Mutation> in
                    return .just(.setError(error))
                },
            .just(.setLoading(false))
        ])
    }
    
    // 친구 요청 보내기
    private func sendFriendRequest(email: String) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            friendshipService.sendFriendRequest(email: email)
                .flatMap { [weak self] _ -> Observable<Mutation> in
                    guard let self = self else { return .empty() }
                    // 친구 요청 후 현재 모드에 따라 목록 다시 로드
                    if self.currentState.viewMode == .friendsList {
                        return self.friendshipService.getFriends()
                            .map { Mutation.setFriends($0) }
                    } else {
                        return self.friendshipService.searchFriendByEmail(email: email)
                            .map { Mutation.setSearchResults($0) }
                    }
                }
                .catch { error -> Observable<Mutation> in
                    return .just(.setError(error))
                },
            .just(.setLoading(false))
        ])
    }
    
    // 친구 삭제
    private func removeFriend(friendshipId: String) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            friendshipService.removeFriend(id: friendshipId)
                .flatMap { [weak self] success -> Observable<Mutation> in
                    guard let self = self, success else {
                        return .just(.setError(NetworkError.serverError("친구 삭제에 실패했습니다.")))
                    }
                    
                    // 친구 삭제 후 현재 모드에 따라 목록 다시 로드
                    if self.currentState.viewMode == .friendsList {
                        return self.friendshipService.getFriends()
                            .map { Mutation.setFriends($0) }
                    } else {
                        // 검색 모드에서는 해당 친구의 상태만 업데이트
                        var updatedResults = self.currentState.searchResults
                        if let index = updatedResults.firstIndex(where: { $0.friendshipId == friendshipId }) {
                            var updatedResult = updatedResults[index]
                            updatedResult.friendshipStatus = nil
                            updatedResult.friendshipId = nil
                            updatedResults[index] = updatedResult
                        }
                        return .just(.setSearchResults(updatedResults))
                    }
                }
                .catch { error -> Observable<Mutation> in
                    return .just(.setError(error))
                },
            .just(.setLoading(false))
        ])
    }
}
