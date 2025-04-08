//
//  EmailLoginViewModel.swift
//  Packing
//
//  Created by 이융의 on 3/31/25.
//

import Foundation
import RxSwift
import RxCocoa

class EmailLoginViewModel {
    
    // MARK: - Dependencies
    
    private let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Input & Output
    
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let loginTap: Observable<Void>
        let signUpTap: Observable<Void>
    }
    
    struct Output {
        let isLoginEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let loginResult: Driver<Result<User, AuthError>>
        let showSignUp: Driver<Void>
        let errorMessage: Driver<String>
    }
    
    // MARK: - Initialization
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        // 상태 관리를 위한 Relay
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let loginResultRelay = PublishRelay<Result<User, AuthError>>()
        let errorMessageRelay = PublishRelay<String>()
        
        // 이메일과 비밀번호 유효성 검사
        let isValidCredentials = Observable.combineLatest(
            input.email, input.password
        ) { email, password in
            return self.isValidEmail(email) && password.count >= 6
        }.startWith(false)
        
        // 로그인 버튼 탭 이벤트 처리
        input.loginTap
            .withLatestFrom(Observable.combineLatest(input.email, input.password))
            .flatMapLatest { [weak self] email, password -> Observable<Result<TokenData, AuthError>> in
                guard let self = self else { return .empty() }
                
                isLoadingRelay.accept(true)
                
                return self.authService.login(email: email, password: password)
                    .map { Result<TokenData, AuthError>.success($0) }
                    .catch { error -> Observable<Result<TokenData, AuthError>> in
                        if let authError = error as? AuthError {
                            return .just(.failure(authError))
                        } else {
                            return .just(.failure(.loginFailed))
                        }
                    }
                    .do(onNext: { _ in
                        isLoadingRelay.accept(false)
                    }, onError: { _ in
                        isLoadingRelay.accept(false)
                    })
            }
            .subscribe(onNext: { result in
                switch result {
                case .success(let tokenData):
                    loginResultRelay.accept(.success(tokenData.user))
                case .failure(let error):
                    loginResultRelay.accept(.failure(error))
                    errorMessageRelay.accept(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
        // 출력값 구성
        return Output(
            isLoginEnabled: isValidCredentials.asDriver(onErrorJustReturn: false),
            isLoading: isLoadingRelay.asDriver(),
            loginResult: loginResultRelay.asDriver(onErrorJustReturn: .failure(.loginFailed)),
            showSignUp: input.signUpTap.asDriver(onErrorJustReturn: ()),
            errorMessage: errorMessageRelay.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        )
    }
    
    // MARK: - Helper Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
