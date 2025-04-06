//
//  EmailSignUpReactor.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa

class EmailSignUpReactor: Reactor {
    enum Action {
        case updateEmail(String)
        case updatePassword(String)
        case updatePasswordConfirm(String)
        case updateName(String)
        case validateForm
        case goToVerification
    }
    
    enum Mutation {
        case setEmail(String)
        case setPassword(String)
        case setPasswordConfirm(String)
        case setName(String)
        case setEmailValidation(Bool, String?)
        case setPasswordValidation(Bool, String?)
        case setPasswordConfirmValidation(Bool, String?)
        case setNameValidation(Bool, String?)
        case setFormValidation(Bool)
        case navigateToVerification
    }
    
    struct State {
        var email: String = ""
        var password: String = ""
        var passwordConfirm: String = ""
        var name: String = ""
        
        var isEmailValid: Bool = false
        var emailErrorMessage: String? = nil
        
        var isPasswordValid: Bool = false
        var passwordErrorMessage: String? = nil
        
        var isPasswordConfirmValid: Bool = false
        var passwordConfirmErrorMessage: String? = nil
        
        var isNameValid: Bool = false
        var nameErrorMessage: String? = nil
        
        var isFormValid: Bool = false
        var isNavigatingToVerification: Bool = false
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateEmail(email):
            let isValid = validateEmail(email: email)
            let errorMessage = isValid ? nil : "유효한 이메일 주소를 입력하세요."
            
            return Observable.concat([
                Observable.just(Mutation.setEmail(email)),
                Observable.just(Mutation.setEmailValidation(isValid, errorMessage)),
                Observable.just(Mutation.setFormValidation(checkFormValidity()))
            ])
            
        case let .updatePassword(password):
            let isValid = validatePassword(password: password)
            let errorMessage = isValid ? nil : "영문, 숫자를 조합한 8~20자리를 입력하세요."
            
            // 비밀번호 확인 검증도 같이 수행
            let isConfirmValid = validatePasswordMatch(password: password, confirm: currentState.passwordConfirm)
            let confirmErrorMessage = isConfirmValid ? nil : "비밀번호가 일치하지 않습니다."
            
            return Observable.concat([
                Observable.just(Mutation.setPassword(password)),
                Observable.just(Mutation.setPasswordValidation(isValid, errorMessage)),
                Observable.just(Mutation.setPasswordConfirmValidation(isConfirmValid, confirmErrorMessage)),
                Observable.just(Mutation.setFormValidation(checkFormValidity()))
            ])
            
        case let .updatePasswordConfirm(passwordConfirm):
            let isValid = validatePasswordMatch(password: currentState.password, confirm: passwordConfirm)
            let errorMessage = isValid ? nil : "비밀번호가 일치하지 않습니다."
            
            return Observable.concat([
                Observable.just(Mutation.setPasswordConfirm(passwordConfirm)),
                Observable.just(Mutation.setPasswordConfirmValidation(isValid, errorMessage)),
                Observable.just(Mutation.setFormValidation(checkFormValidity()))
            ])
            
        case let .updateName(name):
            let isValid = validateName(name: name)
            let errorMessage = isValid ? nil : "이름은 20자 이내로 입력해주세요."
            
            return Observable.concat([
                Observable.just(Mutation.setName(name)),
                Observable.just(Mutation.setNameValidation(isValid, errorMessage)),
                Observable.just(Mutation.setFormValidation(checkFormValidity()))
            ])
            
        case .validateForm:
            return Observable.just(Mutation.setFormValidation(checkFormValidity()))
            
        case .goToVerification:
            return Observable.just(Mutation.navigateToVerification)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setEmail(email):
            newState.email = email
            
        case let .setPassword(password):
            newState.password = password
            
        case let .setPasswordConfirm(passwordConfirm):
            newState.passwordConfirm = passwordConfirm
            
        case let .setName(name):
            newState.name = name
            
        case let .setEmailValidation(isValid, errorMessage):
            newState.isEmailValid = isValid
            newState.emailErrorMessage = errorMessage
            
        case let .setPasswordValidation(isValid, errorMessage):
            newState.isPasswordValid = isValid
            newState.passwordErrorMessage = errorMessage
            
        case let .setPasswordConfirmValidation(isValid, errorMessage):
            newState.isPasswordConfirmValid = isValid
            newState.passwordConfirmErrorMessage = errorMessage
            
        case let .setNameValidation(isValid, errorMessage):
            newState.isNameValid = isValid
            newState.nameErrorMessage = errorMessage
            
        case let .setFormValidation(isValid):
            newState.isFormValid = isValid
            
        case .navigateToVerification:
            newState.isNavigatingToVerification = true
        }
        
        return newState
    }
    
    // MARK: - Private Methods
    
    private func checkFormValidity() -> Bool {
        return currentState.isEmailValid &&
               currentState.isPasswordValid &&
               currentState.isPasswordConfirmValid &&
               currentState.isNameValid
    }
    
    private func validateEmail(email: String) -> Bool {
        if email.isEmpty { return false }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validatePassword(password: String) -> Bool {
        if password.isEmpty { return false }
        
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d\\W_]{8,20}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func validatePasswordMatch(password: String, confirm: String) -> Bool {
        if confirm.isEmpty { return false }
        return password == confirm
    }
    
    private func validateName(name: String) -> Bool {
        if name.isEmpty { return false }
        return name.count <= 20
    }
}
