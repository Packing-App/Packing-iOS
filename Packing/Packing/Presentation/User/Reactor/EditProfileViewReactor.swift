//
//  EditProfileViewReactor.swift
//  Packing
//
//  Created by 이융의 on 4/19/25.
//

import ReactorKit
import RxSwift
import RxCocoa
import UIKit

final class EditProfileViewReactor: Reactor {
    enum Action {
        case updateName(String)
        case updateIntro(String)
        case save
        case updateProfileImage(UIImage)
        case cancel
    }
    
    enum Mutation {
        case setName(String)
        case setIntro(String)
        case setLoading(Bool)
        case setError(NetworkError?)
        case setSaveComplete(User)
        case setImageUpdated(String)
    }
    
    struct State {
        var originalUser: User
        var name: String
        var intro: String
        var profileImageUrl: String?
        var tempProfileImage: UIImage?
        var isLoading: Bool = false
        var error: NetworkError?
        var isSaveComplete: Bool = false
        var updatedUser: User?
        
        var isValid: Bool {
            return !name.isEmpty
        }
    }
    
    let initialState: State
    
    private let userService: UserServiceProtocol
    
    init(user: User, userService: UserServiceProtocol = UserService()) {
        self.userService = userService
        self.initialState = State(
            originalUser: user,
            name: user.name,
            intro: user.intro ?? "",
            profileImageUrl: user.profileImage
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateName(name):
            return .just(.setName(name))
            
        case let .updateIntro(intro):
            return .just(.setIntro(intro))
            
        case .save:
            // 이름이 비어있으면 저장 불가
            guard !currentState.name.isEmpty else {
                return .just(.setError(NetworkError.serverError("이름은 필수 입력 항목입니다.".localized)))
            }
            
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                userService.updateProfile(name: currentState.name, intro: currentState.intro)
                    .map { Mutation.setSaveComplete($0) }
                    .catch { error in
                        if let networkError = error as? NetworkError {
                            return .just(Mutation.setError(networkError))
                        }
                        return .just(Mutation.setError(.unknown))
                    },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case let .updateProfileImage(image):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                userService.updateProfileImage(image: image)
                    .map { Mutation.setImageUpdated($0) }
                    .catch { error in
                        if let networkError = error as? NetworkError {
                            return .just(Mutation.setError(networkError))
                        }
                        return .just(Mutation.setError(.unknown))
                    },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .cancel:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setName(name):
            newState.name = name
            
        case let .setIntro(intro):
            newState.intro = intro
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setError(error):
            newState.error = error
            newState.isLoading = false
            
        case let .setSaveComplete(user):
            newState.updatedUser = user
            newState.isSaveComplete = true
            newState.isLoading = false
            
        case let .setImageUpdated(imageUrl):
            newState.profileImageUrl = imageUrl
            // 프로필 이미지가 업데이트되면 원래 유저 객체도 업데이트
            var updatedUser = newState.originalUser
            updatedUser.profileImage = imageUrl
            newState.originalUser = updatedUser
            newState.tempProfileImage = nil
        }
        
        return newState
    }
}
