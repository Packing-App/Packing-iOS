//
//  LoginReactor.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import ReactorKit
import RxSwift
import RxCocoa

final class LoginViewReactor: Reactor {
    
    enum Action {
        case emailLogin
    }
    
    // 상태 변화의 중간 단계 Mutation 정의
    enum Mutation {
        case setLoading(Bool)
        case setSocialLoginResult(Result<TokenData, AuthError>)
        case setError(String)
    }
    
    // View의 상태 정의
    struct State {
        var isLoading: Bool = false
        var loginResult: Result<TokenData, AuthError>?
        var errorMessage: String?
    }
    
    // 초기 상태
    let initialState: State = State()
    
    // 의존성
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    // Action을 Mutation으로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .emailLogin:
            // 이메일 로그인은 화면 전환만 하므로 상태변경 없음
            return .empty()
        }
    }
    
    // Mutation을 기반으로 State 업데이트
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setSocialLoginResult(let result):
            newState.loginResult = result
            newState.isLoading = false
        case .setError(let message):
            newState.errorMessage = message
            newState.isLoading = false
        }
        
        return newState
    }
}
