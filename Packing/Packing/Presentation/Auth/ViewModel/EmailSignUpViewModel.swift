//
//  EmailSignUpViewModel.swift
//  Packing
//
//  Created by 이융의 on 4/8/25.
//

import Foundation
import RxSwift
import RxCocoa

class EmailSignUpViewModel {
    
    // MARK: - Input & Output
    
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let confirmPassword: Observable<String>
        let name: Observable<String>
        let nextButtonTap: Observable<Void>
    }
    
    struct Output {
        let isEmailValid: Driver<Bool>
        let emailErrorMessage: Driver<String?>
        
        let isPasswordValid: Driver<Bool>
        let passwordErrorMessage: Driver<String?>
        
        let isConfirmPasswordValid: Driver<Bool>
        let confirmPasswordErrorMessage: Driver<String?>
        
        let isNameValid: Driver<Bool>
        let nameErrorMessage: Driver<String?>
        
        let isNextButtonEnabled: Driver<Bool>
        
        let isLoading: Driver<Bool>
        let errorMessage: Driver<String>
        
        // 회원가입 성공 결과를 전달하는 output driver
        let registerSuccess: Driver<(String, String, String, TokenData)>
    }
    
    // MARK: - Dependencies
    
    let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    private let emailSubject = BehaviorRelay<String>(value: "")
    private let passwordSubject = BehaviorRelay<String>(value: "")
    private let nameSubject = BehaviorRelay<String>(value: "")
    
    // MARK: - Initialization
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        // 상태 관리를 위한 Relay
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let errorMessageRelay = PublishRelay<String>()
        
        // PublishRelay: 에러 이벤트 방출안함. '완료'되는 것이 아닌, 항상 활성 상태 유지 (새로운 회원가입 시도 가능)
        // PublishRelay는 onNext,onError,onCompleted가 아니라, accept 를 통해 새 값을 발행 가능
        let registerSuccessRelay = PublishRelay<(String, String, String, TokenData)>()
        
        // 이메일, 비밀번호, 이름 구독 및 저장
        input.email
            .bind(to: emailSubject)
            .disposed(by: disposeBag)
        
        input.password
            .bind(to: passwordSubject)
            .disposed(by: disposeBag)
        
        input.name
            .bind(to: nameSubject)
            .disposed(by: disposeBag)
        
        // 이메일 유효성 검사
        let isEmailValid = input.email
            .map { [weak self] email in
                guard let self = self else { return false }
                return self.isValidEmail(email)
            }
        
        let emailErrorMessage = input.email
            .map { [weak self] email in
                guard let self = self, !email.isEmpty else { return nil as String? }
                return self.isValidEmail(email) ? nil : "유효한 이메일 주소를 입력하세요.".localized
            }
        
        // 비밀번호 유효성 검사
        let isPasswordValid = input.password
            .map { [weak self] password in
                guard let self = self else { return false }
                return self.isValidPassword(password)
            }
        
        let passwordErrorMessage = input.password
            .map { [weak self] password in
                guard let self = self, !password.isEmpty else { return nil as String? }
                return self.isValidPassword(password) ? nil : "영문, 숫자를 조합한 8~20자리를 입력하세요.".localized
            }
        
        // 비밀번호 확인 유효성 검사
        let isConfirmPasswordValid = Observable.combineLatest(input.password, input.confirmPassword)
            .map { password, confirmPassword in
                !confirmPassword.isEmpty && password == confirmPassword
            }
        
        let confirmPasswordErrorMessage = Observable.combineLatest(input.password, input.confirmPassword)
            .map { password, confirmPassword in
                if confirmPassword.isEmpty {
                    return nil as String?
                }
                return password == confirmPassword ? nil : "비밀번호가 일치하지 않습니다.".localized
            }
        
        // 이름 유효성 검사
        let isNameValid = input.name
            .map { name in
                !name.isEmpty && name.count <= 20
            }
        
        let nameErrorMessage = input.name
            .map { name in
                if name.isEmpty {
                    return nil as String?
                }
                return name.count <= 20 ? nil : "이름은 20자 이내로 입력해주세요.".localized
            }
        
        // 다음 버튼 활성화 여부
        let isNextButtonEnabled = Observable.combineLatest(
            isEmailValid, isPasswordValid, isConfirmPasswordValid, isNameValid
        ) { isEmailValid, isPasswordValid, isConfirmPasswordValid, isNameValid in
            return isEmailValid && isPasswordValid && isConfirmPasswordValid && isNameValid
        }
        
        // 다음 버튼 클릭 처리 - 서버에 회원가입 요청.(중요)
        input.nextButtonTap
            .withLatestFrom(Observable.combineLatest(
                emailSubject, passwordSubject, nameSubject
            ))
            .do(onNext: { _ in isLoadingRelay.accept(true) })
            .flatMapLatest { [weak self] (email, password, name) -> Observable<Result<TokenData, AuthError>> in
                guard let self = self else { return .empty() }
                
                return self.authService.registerUser(name: name, email: email, password: password)
                    .map { Result<TokenData, AuthError>.success($0) }
                    .catch { error -> Observable<Result<TokenData, AuthError>> in
                        let authError = error as? AuthError ?? AuthError.loginFailed
                        return Observable.just(.failure(authError))
                    }
            }
            .do(onNext: { _ in isLoadingRelay.accept(false) })
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let tokenData):
                    // 회원가입 성공 - 이메일, 비밀번호, 이름과 함께 토큰 데이터 전달
                    registerSuccessRelay.accept((
                        self.emailSubject.value,
                        self.passwordSubject.value,
                        self.nameSubject.value,
                        tokenData
                    ))
                case .failure(let error):
                    // 회원가입 실패 - 에러 메시지 전달
                    errorMessageRelay.accept(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
        
        // 출력값 구성
        return Output(
            isEmailValid: isEmailValid.asDriver(onErrorJustReturn: false),
            emailErrorMessage: emailErrorMessage.asDriver(onErrorJustReturn: nil),
            
            isPasswordValid: isPasswordValid.asDriver(onErrorJustReturn: false),
            passwordErrorMessage: passwordErrorMessage.asDriver(onErrorJustReturn: nil),
            
            isConfirmPasswordValid: isConfirmPasswordValid.asDriver(onErrorJustReturn: false),
            confirmPasswordErrorMessage: confirmPasswordErrorMessage.asDriver(onErrorJustReturn: nil),
            
            isNameValid: isNameValid.asDriver(onErrorJustReturn: false),
            nameErrorMessage: nameErrorMessage.asDriver(onErrorJustReturn: nil),
            
            isNextButtonEnabled: isNextButtonEnabled.asDriver(onErrorJustReturn: false),
            
            isLoading: isLoadingRelay.asDriver(),
            errorMessage: errorMessageRelay.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.".localized),
            registerSuccess: registerSuccessRelay.asDriver(onErrorJustReturn: ("", "", "", TokenData(accessToken: "", refreshToken: "", user: User.exampleUser)))
        )
    }
    
    // MARK: - Validation Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // Password must contain letters and numbers, and be 8-20 characters long
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d\\W_]{8,20}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}
