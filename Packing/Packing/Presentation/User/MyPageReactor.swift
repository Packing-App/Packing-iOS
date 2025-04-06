//
//  MyPageReactor.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa
import UIKit

class MyPageReactor: Reactor {
    enum Action {
        case loadProfile
        case updateName(String)
        case updateIntro(String)
        case saveProfile
        case updateProfileImage(UIImage)
        case logout
        case deleteAccount
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setProfile(User)
        case setName(String)
        case setIntro(String)
        case setProfileImage(String?)
        case setLoggedOut(Bool)
        case setAccountDeleted(Bool)
        case setError(Error)
    }
    
    struct State {
        var isLoading: Bool = false
        var user: User?
        var name: String = ""
        var intro: String = ""
        var profileImage: String?
        var isLoggedOut: Bool = false
        var isAccountDeleted: Bool = false
        var isSaveEnabled: Bool = false
        var error: Error?
    }
    
    let initialState = State()
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(userService: UserServiceProtocol, authService: AuthServiceProtocol) {
        self.userService = userService
        self.authService = authService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadProfile:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                userService.getMyProfile()
                    .map { Mutation.setProfile($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case let .updateName(name):
            return Observable.just(Mutation.setName(name))
            
        case let .updateIntro(intro):
            return Observable.just(Mutation.setIntro(intro))
            
        case .saveProfile:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                userService.updateProfile(name: currentState.name, intro: currentState.intro)
                    .map { Mutation.setProfile($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case let .updateProfileImage(image):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                userService.updateProfileImage(image: image)
                    .map { Mutation.setProfileImage($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .logout:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.logout()
                    .map { Mutation.setLoggedOut($0) }
                    .catch { Observable.just(Mutation.setError($0)) },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .deleteAccount:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                authService.deleteAccount()
                    .map { Mutation.setAccountDeleted($0) }
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
            
        case let .setProfile(user):
            newState.user = user
            newState.name = user.name
            newState.intro = user.intro ?? ""
            newState.profileImage = user.profileImage
            newState.error = nil
            newState.isSaveEnabled = false // 초기 상태에서는 저장 비활성화
            
        case let .setName(name):
            newState.name = name
            // 이름이 변경되었으면 저장 버튼 활성화
            newState.isSaveEnabled = name != newState.user?.name || newState.intro != newState.user?.intro
            
        case let .setIntro(intro):
            newState.intro = intro
            // 자기소개가 변경되었으면 저장 버튼 활성화
            newState.isSaveEnabled = intro != newState.user?.intro || newState.name != newState.user?.name
            
        case let .setProfileImage(imageUrl):
            newState.profileImage = imageUrl
            
        case let .setLoggedOut(isLoggedOut):
            newState.isLoggedOut = isLoggedOut
            
        case let .setAccountDeleted(isDeleted):
            newState.isAccountDeleted = isDeleted
            
        case let .setError(error):
            newState.error = error
        }
        
        return newState
    }
}
