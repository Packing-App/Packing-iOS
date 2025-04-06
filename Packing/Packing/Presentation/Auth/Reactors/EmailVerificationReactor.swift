//
//  EmailVerificationReactor.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class EmailVerificationReactor: Reactor {
    enum Action {
        case updateCode(String)
        case verifyCode
        case resendCode
        case register
    }
    
    enum Mutation {
        case setCode(String)
        case setCodeValidation(Bool, String?)
        case setLoading(Bool)
        case setVerificationComplete(Bool)
        case setResendComplete(Bool)
        case setRegisterComplete(User)
        case setError(Error)
    }
    
    struct State {
        var email: String
        var password: String
        var name: String
        var code: String = ""
        
        var isCodeValid: Bool = false
        var codeErrorMessage: String? = nil
        var isLoading: Bool = false
        var isVerificationComplete: Bool = false
        var isResendComplete: Bool = false
        var user: User? = nil
        var error: Error? = nil
        
        init(email: String, password: String, name: String) {
            self.email = email
            self.password = password
            self.name = name
        }
    }
    
    let initialState: State
    private let authService: AuthService
    
    init(authService: AuthService, email: String, password: String, name: String) {
        self.authService = authService
        self.initialState = State(email: email, password: password, name: name)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateCode(code):
            let isValid = validateCode(code: code)
            let errorMessage = isValid ? nil : "6자리 숫자를 입력해주세요."
            
            return Observable.concat([
                Observable.just(Mutation.setCode(code)),
                Observable.just(Mutation.setCodeValidation(isValid, errorMessage))
            ])
            
        case .verifyCode:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.verifyEmail(email: currentState.email, code: currentState.code)
                    .map { Mutation.setVerificationComplete($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .resendCode:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.resendVerificationCode(email: currentState.email)
                    .map { Mutation.setResendComplete($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .register:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.registerUser(name: currentState.name, email: currentState.email, password: currentState.password)
                    .map { Mutation.setRegisterComplete($0.user) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setCode(code):
            newState.code = code
            
        case let .setCodeValidation(isValid, errorMessage):
            newState.isCodeValid = isValid
            newState.codeErrorMessage = errorMessage
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setVerificationComplete(isComplete):
            newState.isVerificationComplete = isComplete
            // 인증 완료 후 자동으로 회원가입 진행
            newState.error = nil
            
        case let .setResendComplete(isComplete):
            newState.isResendComplete = isComplete
            // 재전송 성공 후 재설정
            if isComplete {
                newState.code = ""
                newState.isCodeValid = false
                newState.codeErrorMessage = "인증번호가 재전송되었습니다."
            }
            newState.error = nil
            
        case let .setRegisterComplete(user):
            newState.user = user
            newState.error = nil
            
        case let .setError(error):
            newState.error = error
        }
        
        return newState
    }
    
    // MARK: - Private Methods
    
    private func validateCode(code: String) -> Bool {
        if code.isEmpty { return false }
        
        let codeRegEx = "^[0-9]{6}$"
        let codePredicate = NSPredicate(format: "SELF MATCHES %@", codeRegEx)
        return codePredicate.evaluate(with: code)
    }
}
