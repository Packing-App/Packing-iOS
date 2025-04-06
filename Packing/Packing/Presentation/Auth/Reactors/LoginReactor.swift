//
//  LoginReactor.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import ReactorKit
import RxSwift
import RxCocoa
import Foundation
import UIKit

class LoginReactor: Reactor {
    enum Action {
        case emailLogin
        case googleLogin
        case kakaoLogin
        case naverLogin
        case appleLogin
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoggedIn(User)
        case setError(Error)
        case navigateToEmailLogin
    }
    
    struct State {
        var isLoading: Bool = false
        var user: User?
        var error: Error?
        var isNavigatingToEmailLogin: Bool = false
    }
    
    let initialState = State()
    private let authService: AuthService
    private let presentingViewController: UIViewController
    
    init(authService: AuthService, presentingViewController: UIViewController) {
        self.authService = authService
        self.presentingViewController = presentingViewController
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .emailLogin:
            return Observable.just(Mutation.navigateToEmailLogin)
            
        case .googleLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.handleSocialLogin(from: presentingViewController, type: .google)
                    .map { Mutation.setLoggedIn($0.user) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .kakaoLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.handleSocialLogin(from: presentingViewController, type: .kakao)
                    .map { Mutation.setLoggedIn($0.user) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .naverLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.handleSocialLogin(from: presentingViewController, type: .naver)
                    .map { Mutation.setLoggedIn($0.user) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .appleLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.handleAppleLogin(from: presentingViewController)
                    .map { Mutation.setLoggedIn($0.user) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setLoggedIn(user):
            newState.user = user
            newState.error = nil
            
        case let .setError(error):
            newState.error = error
            
        case .navigateToEmailLogin:
            newState.isNavigatingToEmailLogin = true
        }
        
        return newState
    }
}
