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
        case googleLogin
        case kakaoLogin
        case naverLogin
        case appleLogin
//        case handleCallback(url: URL)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoggedIn(AuthResult?)
        case setError(Error?)
    }
    
    struct State {
        var isLoading: Bool = false
        var authResult: AuthResult? = nil
        var error: Error? = nil
    }
    
    let initialState = State()
    private let socialLoginService: SocialLoginService
    private let viewController: UIViewController    // ??? 지금 이거 강한참조?

    init(socialLoginService: SocialLoginService, viewController: UIViewController) {
        self.socialLoginService = socialLoginService
        self.viewController = viewController
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .googleLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                socialLoginService.performOAuthLogin(for: .google, from: viewController)
                    .map { Mutation.setLoggedIn($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .kakaoLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                socialLoginService.performOAuthLogin(for: .kakao, from: viewController)
                    .map { Mutation.setLoggedIn($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .naverLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                socialLoginService.performOAuthLogin(for: .naver, from: viewController)
                    .map { Mutation.setLoggedIn($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .appleLogin:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                socialLoginService.performAppleLogin(from: viewController)
                    .map { Mutation.setLoggedIn($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setLoggedIn(let authResult):
            newState.authResult = authResult
            newState.error = nil
            
        case .setError(let error):
            newState.error = error
        }
        
        return newState
    }
}
