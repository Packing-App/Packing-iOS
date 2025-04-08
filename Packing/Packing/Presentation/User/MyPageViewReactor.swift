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

final class MyPageViewReactor: Reactor {
    // 사용자 액션 정의
    enum Action {
        case refresh
        case editProfile
        case logout
        case deleteAccount
    }
    
    // 상태 변화의 중간 단계 정의
    enum Mutation {
        case setUser(User?)
        case setLoading(Bool)
        case setError(String)
    }
    
    // 뷰 상태 정의
    struct State {
        var user: User?
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    let initialState: State
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    private let userManager: UserManager
    
    init(
        user: User? = nil,
        userService: UserServiceProtocol = UserService(),
        authService: AuthServiceProtocol = AuthService.shared,
        userManager: UserManager = UserManager.shared
    ) {
        // 초기 상태 설정
        self.initialState = State(user: user ?? userManager.currentUser)
        self.userService = userService
        self.authService = authService
        self.userManager = userManager
    }
    
    // Action을 Mutation으로 변환
    func mutate(action: Action) -> Observable<Mutation> {
        print(#fileID, #function, #line, "- ")
        print(action)
        switch action {
        case .refresh:
            return refreshUserProfile()
            
        case .editProfile:
            // 편집 화면으로 이동하는 것은 View에서 처리
            return .empty()
            
        case .logout:
            return performLogout()
            
        case .deleteAccount:
            return performDeleteAccount()
        }
    }
    
    // Mutation을 기반으로 State 업데이트
    func reduce(state: State, mutation: Mutation) -> State {
        print(#fileID, #function, #line, "- ")
        print(mutation)
        var newState = state
        
        switch mutation {
        case .setUser(let user):
            newState.user = user
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    // 사용자 프로필 새로고침
    private func refreshUserProfile() -> Observable<Mutation> {
        print("refreshUserProfile 시작")
        
        let startLoading = Observable.just(Mutation.setLoading(true))
        
        let refreshProfile = userService.getMyProfile()
            .map { user -> Mutation in
                print("User 매핑 중")
                return .setUser(user)
            }
            .catch { error -> Observable<Mutation> in
                print("Error in profile: \(error)")
                let errorMessage = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
                return .just(.setError(errorMessage))
            }
        
        let endLoading = Observable.just(Mutation.setLoading(false))
            .do(onNext: { _ in print("endLoading 실행됨") })
        
        // 더 안전한 방식으로 Observable 체인 구성
        return Observable.concat([
            startLoading,
            refreshProfile,
            endLoading
        ])
        .catch { error -> Observable<Mutation> in
            print("refreshUserProfile 에러 발생: \(error)")
            return .concat([
                .just(.setError("프로필 로드 중 오류 발생")),
                .just(.setLoading(false))
            ])
        }
        .do(onNext: { print("Final mutation: \($0)") },
            onError: { print("Final error: \($0)") },
            onCompleted: { print("refreshUserProfile 완료") })
    }
    
//    private func refreshUserProfile() -> Observable<Mutation> {
//        
//        let startLoading = Observable.just(Mutation.setLoading(true))
//        
//        let refreshProfile = userService.getMyProfile()
//            .map { user -> Mutation in
//                return .setUser(user)
//            }
//            .catch { error -> Observable<Mutation> in
//                let errorMessage = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
//                return .just(.setError(errorMessage))
//            }
//        
//        let endLoading = Observable.just(Mutation.setLoading(false))
//        
//        return .concat(startLoading, refreshProfile, endLoading)
//    }
    
    // 로그아웃 수행
    private func performLogout() -> Observable<Mutation> {
        print("로그아웃 프로세스 시작")
        
        let startLoading = Observable.just(Mutation.setLoading(true))
            .do(onNext: { _ in print("로딩 상태 true로 설정") })
        
        let logout = authService.logout()
            .do(onNext: { success in print("로그아웃 결과: \(success)") },
                onError: { error in print("로그아웃 API 오류: \(error)") })
            .map { success -> Mutation in
                print("로그아웃 결과를 Mutation으로 변환")
                if success {
                    print("로그아웃 성공, 사용자 null로 설정")
                    return .setUser(nil)
                } else {
                    print("로그아웃 실패 (success=false)")
                    return .setError("로그아웃에 실패했습니다.")
                }
            }
            .catch { error -> Observable<Mutation> in
                print("로그아웃 중 오류 발생: \(error)")
                // 오류 발생해도 로컬에서는 로그아웃 처리
                return .just(.setUser(nil))
            }
            // 중요: 이 작업에 타임아웃 추가
            .timeout(DispatchTimeInterval.seconds(10), scheduler: MainScheduler.instance)
        
        let endLoading = Observable.just(Mutation.setLoading(false))
            .do(onNext: { _ in print("로딩 상태 false로 설정") })
        
        // 더 안전한 concat 사용 및 완료 보장
        return Observable.concat([startLoading, logout, endLoading])
            .catch { error -> Observable<Mutation> in
                print("로그아웃 시퀀스 오류: \(error)")
                // 항상 시퀀스 완료
                return .concat([
                    .just(.setUser(nil)),
                    .just(.setLoading(false))
                ])
            }
    }
    
    // 계정 삭제 수행
    private func performDeleteAccount() -> Observable<Mutation> {
        let startLoading = Observable.just(Mutation.setLoading(true))
        
        let deleteAccount = authService.deleteAccount()
            .map { success -> Mutation in
                if success {
                    return .setUser(nil)
                } else {
                    return .setError("계정 삭제에 실패했습니다.")
                }
            }
            .catch { error -> Observable<Mutation> in
                let errorMessage = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
                return .just(.setError(errorMessage))
            }
        
        let endLoading = Observable.just(Mutation.setLoading(false))
        
        return .concat(startLoading, deleteAccount, endLoading)
    }
}
