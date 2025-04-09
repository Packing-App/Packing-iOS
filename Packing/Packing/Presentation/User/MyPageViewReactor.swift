//
//  ProfileViewModel.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel {
    // 출력 프로퍼티 (View에 바인딩할 데이터)
    let user = BehaviorRelay<User?>(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let shouldNavigateToLogin = PublishRelay<Void>() // 로그인 화면으로 이동 신호
    
    // 의존성
    private let userService: UserServiceProtocol
    private let authService: AuthServiceProtocol
    private let userManager: UserManager
    private let disposeBag = DisposeBag()
    
    init(
        user: User? = nil,
        userService: UserServiceProtocol = UserService(),
        authService: AuthServiceProtocol = AuthService.shared,
        userManager: UserManager = UserManager.shared
    ) {
        self.userService = userService
        self.authService = authService
        self.userManager = userManager
        
        // UserManager에서 현재 사용자 가져오기
        let initialUser = user ?? userManager.currentUser
        if let initialUser = initialUser {
            self.user.accept(initialUser)
        }
    }
    
    // MARK: - 사용자 액션 처리 함수
    
    func refreshProfile() {
        // 이미 로그인 정보가 없으면 API 호출하지 않음
        if userManager.currentUser == nil && user.value == nil {
            shouldNavigateToLogin.accept(())
            return
        }
        
        isLoading.accept(true)
        
        userService.getMyProfile()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] user in
                    self?.user.accept(user)
                    self?.isLoading.accept(false)
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    
                    // 401 Unauthorized 에러인 경우 로그인 화면으로 이동
                    if let networkError = error as? NetworkError,
                       case .unauthorized = networkError {
                        self?.userManager.clearCurrentUser()
                        self?.shouldNavigateToLogin.accept(())
                    } else {
                        self?.errorMessage.accept(error.localizedDescription)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    func logout() {
        isLoading.accept(true)
        
        authService.logout()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] success in
                    self?.isLoading.accept(false)
                    if success {
                        // 로그아웃 성공 - UserManager와 ViewModel 모두 초기화
                        self?.userManager.clearCurrentUser()
                        self?.user.accept(nil)
                        self?.shouldNavigateToLogin.accept(())
                    } else {
                        self?.errorMessage.accept("로그아웃에 실패했습니다.")
                        // 서버 로그아웃이 실패해도 로컬에서는 로그아웃 처리
                        self?.userManager.clearCurrentUser()
                        self?.user.accept(nil)
                        self?.shouldNavigateToLogin.accept(())
                    }
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    self?.errorMessage.accept(error.localizedDescription)
                    // 로그아웃 실패해도 로컬에서는 로그아웃 처리
                    self?.userManager.clearCurrentUser()
                    self?.user.accept(nil)
                    self?.shouldNavigateToLogin.accept(())
                }
            )
            .disposed(by: disposeBag)
    }
    
    func deleteAccount() {
        isLoading.accept(true)
        
        authService.deleteAccount()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] success in
                    self?.isLoading.accept(false)
                    if success {
                        // 계정 삭제 성공
                        self?.userManager.clearCurrentUser()
                        self?.user.accept(nil)
                        self?.shouldNavigateToLogin.accept(())
                    } else {
                        self?.errorMessage.accept("계정 삭제에 실패했습니다.")
                    }
                },
                onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    self?.errorMessage.accept(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
}
