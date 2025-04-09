//
//  EmailVerificationViewModel.swift
//  Packing
//
//  Created by 이융의 on 4/8/25.
//

import Foundation
import RxSwift
import RxCocoa

class EmailVerificationViewModel {
    
    // MARK: - Input & Output
    
    struct Input {
        let verificationCode: Observable<String>
        let resendButtonTap: Observable<Void>
        let completeButtonTap: Observable<Void>
    }
    
    struct Output {
        let isCodeValid: Driver<Bool>
        let codeErrorMessage: Driver<String?>
        let isCompleteButtonEnabled: Driver<Bool>
        
        let isLoading: Driver<Bool>
        let verificationMessage: Driver<String?>
        let resendButtonEnabled: Driver<Bool>
        
        let signUpResult: Driver<Result<User, AuthError>>
        let errorMessage: Driver<String>
    }
    
    // MARK: - Properties
    
    let email: String
    let password: String
    let name: String
    let tokenData: TokenData
    let authService: AuthServiceProtocol
    
    private let verificationCodeSubject = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(email: String, password: String, name: String, tokenData: TokenData, authService: AuthServiceProtocol = AuthService.shared) {
        self.email = email
        self.password = password
        self.name = name
        self.tokenData = tokenData
        self.authService = authService
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        // 상태 관리를 위한 Relay
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let signUpResultRelay = PublishRelay<Result<User, AuthError>>()
        let errorMessageRelay = PublishRelay<String>()
        let verificationMessageRelay = BehaviorRelay<String?>(value: "인증 코드가 이메일로 발송되었습니다.")
        let resendButtonEnabledRelay = BehaviorRelay<Bool>(value: true)
        
        // 인증 코드 구독 및 저장
        input.verificationCode
            .bind(to: verificationCodeSubject)
            .disposed(by: disposeBag)
        
        // 인증 코드 유효성 검사
        let isCodeValid = input.verificationCode
            .map { [weak self] code in
                guard let self = self else { return false }
                return self.isValidCode(code)
            }
        
        let codeErrorMessage = input.verificationCode
            .map { [weak self] code in
                guard let self = self, !code.isEmpty else { return nil as String? }
                return self.isValidCode(code) ? nil : "6자리 숫자를 입력해주세요."
            }
        
        // 완료 버튼 활성화 여부
        let isCompleteButtonEnabled = isCodeValid
        
        // 인증 코드 재전송 버튼 이벤트 처리
        input.resendButtonTap
            .do(onNext: { _ in
                isLoadingRelay.accept(true)
                resendButtonEnabledRelay.accept(false)
            })
            .flatMapLatest { [weak self] _ -> Observable<Result<Bool, AuthError>> in
                guard let self = self else { return .empty() }
                
                return self.authService.resendVerificationCode(email: self.email)
                    .map { Result<Bool, AuthError>.success($0) }
                    .catch { error -> Observable<Result<Bool, AuthError>> in
                        let authError = error as? AuthError ?? AuthError.loginFailed
                        return Observable.just(Result<Bool, AuthError>.failure(authError))
                    }
            }
            .do(onNext: { _ in
                isLoadingRelay.accept(false)
                
                // 3초 후에 재전송 버튼 다시 활성화
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    resendButtonEnabledRelay.accept(true)
                }
            })
            .subscribe(onNext: { result in
                switch result {
                case .success:
                    verificationMessageRelay.accept("인증번호가 재발송되었습니다.")
                    
                    // 3초 후 메시지 숨기기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if verificationMessageRelay.value == "인증번호가 재발송되었습니다." {
                            verificationMessageRelay.accept(nil)
                        }
                    }
                    
                case .failure(let error):
                    verificationMessageRelay.accept("인증번호 발송 실패")
                    errorMessageRelay.accept(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
        // 이메일 인증 완료 버튼 이벤트 처리
        input.completeButtonTap
            .withLatestFrom(verificationCodeSubject)
            .do(onNext: { _ in
                isLoadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] code -> Observable<Result<User, AuthError>> in
                guard let self = self else { return .empty() }
                
                return self.authService.verifyEmail(email: self.email, code: code)
                    .map { _ -> Result<User, AuthError> in
                        // 이메일 인증 성공 - tokenData에서 가져온 사용자 정보 반환
                        return .success(self.tokenData.user)
                    }
                    .catch { error -> Observable<Result<User, AuthError>> in
                        let authError = error as? AuthError ?? AuthError.loginFailed
                        return Observable.just(.failure(authError))
                    }
            }
            .do(onNext: { _ in
                isLoadingRelay.accept(false)
            })
            .subscribe(onNext: { result in
                switch result {
                case .success(let user):
                    signUpResultRelay.accept(.success(user))
                case .failure(let error):
                    signUpResultRelay.accept(.failure(error))
                    errorMessageRelay.accept(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
        // 출력값 구성
        return Output(
            isCodeValid: isCodeValid.asDriver(onErrorJustReturn: false),
            codeErrorMessage: codeErrorMessage.asDriver(onErrorJustReturn: nil as String?),
            isCompleteButtonEnabled: isCompleteButtonEnabled.asDriver(onErrorJustReturn: false),
            
            isLoading: isLoadingRelay.asDriver(),
            verificationMessage: verificationMessageRelay.asDriver(),
            resendButtonEnabled: resendButtonEnabledRelay.asDriver(),
            
            signUpResult: signUpResultRelay.asDriver(onErrorJustReturn: .failure(.loginFailed)),
            errorMessage: errorMessageRelay.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        )
    }
    
    // MARK: - Private Methods
    
    private func isValidCode(_ code: String) -> Bool {
        let codeRegex = "^[0-9]{6}$"
        let codePredicate = NSPredicate(format: "SELF MATCHES %@", codeRegex)
        return codePredicate.evaluate(with: code)
    }
}
