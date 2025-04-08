//
//  EmailLoginReactor.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class EmailLoginReactor: Reactor {
    
    enum Action {
        case updateEmail(String)
        case updatePassword(String)
        case login
        case goToSignUp
    }
    
    enum Mutation {
        case setEmail(String)
        case setPassword(String)
        case setLoading(Bool)
        case setLoggedIn(User)
        case setError(Error)
        case navigateToSignUp
    }
    
    struct State {
        var email: String = ""
        var password: String = ""
        var isLoading: Bool = false
        var isLoginEnabled: Bool = false
        var user: User?
        var error: Error?
        var isNavigatingToSignUp: Bool = false
    }
    
    let initialState = State()
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateEmail(email):
            return Observable.just(Mutation.setEmail(email))
            
        case let .updatePassword(password):
            return Observable.just(Mutation.setPassword(password))
            
        case .login:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.login(email: currentState.email, password: currentState.password)
                    .map { Mutation.setLoggedIn($0.user) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .goToSignUp:
            return Observable.just(Mutation.navigateToSignUp)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setEmail(email):
            newState.email = email
            newState.isLoginEnabled = !email.isEmpty && !newState.password.isEmpty
            
        case let .setPassword(password):
            newState.password = password
            newState.isLoginEnabled = !newState.email.isEmpty && !password.isEmpty
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setLoggedIn(user):
            newState.user = user
            newState.error = nil
            
        case let .setError(error):
            newState.error = error
            
        case .navigateToSignUp:
            newState.isNavigatingToSignUp = true
        }
        
        return newState
    }
}
