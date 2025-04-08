//
//  LoginViewModel.swift
//  Packing
//
//  Created by 이융의 on 4/8/25.
//

import RxSwift
import RxCocoa
import UIKit

class LoginViewModel {
    
    // MARK: - Outputs (Observable Properties)
    
    // 로딩 상태
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    // 로그인 결과
    let loginResult = PublishSubject<Result<TokenData, AuthError>>()
    
    // 에러 메시지
    let errorMessage = PublishSubject<String>()
    
    // MARK: - Dependencies
    
    private let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    // MARK: - Public Methods
    
    func performSocialLogin(from viewController: UIViewController, type: LoginType) {
        isLoading.accept(true)
        
        authService.handleSocialLogin(from: viewController, type: type)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] user in
                    self?.isLoading.accept(false)
                    // 로그인 성공 처리
                    let mockTokenData = TokenData(
                        accessToken: "mock-token",
                        refreshToken: "mock-refresh",
                        user: user
                    )
                    self?.loginResult.onNext(.success(mockTokenData))
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    if let authError = error as? AuthError {
                        self?.loginResult.onNext(.failure(authError))
                    } else {
                        let genericError = AuthError.loginFailed
                        self?.loginResult.onNext(.failure(genericError))
                        self?.errorMessage.onNext(error.localizedDescription)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    func performAppleLogin(from viewController: UIViewController) {
        isLoading.accept(true)
        
        authService.handleAppleLogin(from: viewController)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] user in
                    self?.isLoading.accept(false)
                    // 로그인 성공 처리
                    let mockTokenData = TokenData(
                        accessToken: "mock-token",
                        refreshToken: "mock-refresh",
                        user: user
                    )
                    self?.loginResult.onNext(.success(mockTokenData))
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    if let authError = error as? AuthError {
                        self?.loginResult.onNext(.failure(authError))
                    } else {
                        let genericError = AuthError.loginFailed
                        self?.loginResult.onNext(.failure(genericError))
                        self?.errorMessage.onNext(error.localizedDescription)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}
