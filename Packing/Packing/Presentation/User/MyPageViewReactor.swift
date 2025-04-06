//
//  MyPageReactor.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

final class MyPageViewReactor: Reactor {
    // 사용자 액션 정의
    enum Action {
        case refresh
        case editProfile
        case logout
        case deleteAccount
    }
    
    // 상태 변화의 중간 단계 정의
    enum Mutation {
        case setUser(User?)
        case setLoading(Bool)
        case setError(String)
    }
    
    // 뷰 상태 정의
    struct State {
        var user: User?
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    let initialState: State
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    private let userManager: UserManager
    
    init(
        user: User? = nil,
        userService: UserServiceProtocol = UserService(),
        authService: AuthServiceProtocol = AuthService.shared,
        userManager: UserManager = UserManager.shared
    ) {
        // 초기 상태 설정
        self.initialState = State(user: user ?? userManager.currentUser)
        self.userService = userService
        self.authService = authService
        self.userManager = userManager
    }
    
    // Action을 Mutation으로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            return refreshUserProfile()
            
        case .editProfile:
            // 편집 화면으로 이동하는 것은 View에서 처리
            return .empty()
            
        case .logout:
            return performLogout()
            
        case .deleteAccount:
            return performDeleteAccount()
        }
    }
    
    // Mutation을 기반으로 State 업데이트
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setUser(let user):
            newState.user = user
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    // 사용자 프로필 새로고침
    private func refreshUserProfile() -> Observable<Mutation> {
        let startLoading = Observable.just(Mutation.setLoading(true))
        // TODO: remove userService or authService
        let refreshProfile = userService.getMyProfile()
            .map { user -> Mutation in
                return .setUser(user)
            }
            .catch { error -> Observable<Mutation> in
                let errorMessage = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
                return .just(.setError(errorMessage))
            }
        
        let endLoading = Observable.just(Mutation.setLoading(false))
        
        return .concat(startLoading, refreshProfile, endLoading)
    }
    
    // 로그아웃 수행
    private func performLogout() -> Observable<Mutation> {
        let startLoading = Observable.just(Mutation.setLoading(true))
        
        let logout = authService.logout()
            .map { success -> Mutation in
                if success {
                    return .setUser(nil)
                } else {
                    return .setError("로그아웃에 실패했습니다.")
                }
            }
            .catch { error -> Observable<Mutation> in
                let errorMessage = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
                return .just(.setError(errorMessage))
            }
        
        let endLoading = Observable.just(Mutation.setLoading(false))
        
        return .concat(startLoading, logout, endLoading)
    }
    
    // 계정 삭제 수행
    private func performDeleteAccount() -> Observable<Mutation> {
        let startLoading = Observable.just(Mutation.setLoading(true))
        
        let deleteAccount = authService.deleteAccount()
            .map { success -> Mutation in
                if success {
                    return .setUser(nil)
                } else {
                    return .setError("계정 삭제에 실패했습니다.")
                }
            }
            .catch { error -> Observable<Mutation> in
                let errorMessage = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
                return .just(.setError(errorMessage))
            }
        
        let endLoading = Observable.just(Mutation.setLoading(false))
        
        return .concat(startLoading, deleteAccount, endLoading)
    }
}
