//
//  ProfileViewReactor.swift
//  Packing
//
//  Created by 이융의 on 4/19/25.
//

import ReactorKit
import RxSwift
import RxCocoa
import UIKit

final class ProfileViewReactor: Reactor {
    // 사용자 액션 정의
    enum Action {
        case refreshProfile
        case logout
        case deleteAccount
    }
    
    // 상태 변경 중간 단계 이벤트
    enum Mutation {
        case setLoading(Bool)
        case setProfile(User)
        case setError(NetworkError?)
        case prepareForLogout
        case prepareForAccountDeletion
    }
    
    // 화면의 상태 정의
    struct State {
        var user: User?
        var isLoading: Bool = false
        var error: NetworkError?
        var shouldNavigateToLogin: Bool = false
    }
    
    let initialState: State
    
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        userService: UserServiceProtocol = UserService(),
        authService: AuthServiceProtocol = AuthService()
    ) {
        self.userService = userService
        self.authService = authService
        self.initialState = State()
    }
    
    // 뷰로부터 액션을 받아 Mutation으로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refreshProfile:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                userService.getMyProfile()
                    .map { Mutation.setProfile($0) }
                    .catch { error in
                        if let networkError = error as? NetworkError {
                            return .just(Mutation.setError(networkError))
                        }
                        return .just(Mutation.setError(.unknown))
                    },
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .logout:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.logout()
                    .map { _ in Mutation.prepareForLogout }
                    .catch { error in
                        if let networkError = error as? NetworkError {
                            return .just(Mutation.setError(networkError))
                        }
                        return .just(Mutation.setError(.unknown))
                    },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .deleteAccount:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.deleteAccount()
                    .map { _ in Mutation.prepareForAccountDeletion }
                    .catch { error in
                        if let networkError = error as? NetworkError {
                            return .just(Mutation.setError(networkError))
                        }
                        return .just(Mutation.setError(.unknown))
                    },
                
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    // 변이(Mutation)를 받아 상태를 변경
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setProfile(user):
            newState.user = user
            newState.error = nil
            
        case let .setError(error):
            newState.error = error
            
        case .prepareForLogout, .prepareForAccountDeletion:
            newState.shouldNavigateToLogin = true
        }
        
        return newState
    }
}
