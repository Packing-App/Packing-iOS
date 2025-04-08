//
//  AuthService.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import RxSwift
import AuthenticationServices

enum AuthError: Error {
    case apiError(NetworkError)
    case loginFailed
    case userCancelled
    case noData
    
    var localizedDescription: String {
        switch self {
        case .apiError(let error):
            return error.localizedDescription
        case .loginFailed:
            return "로그인에 실패했습니다."
        case .userCancelled:
            return "사용자가 로그인을 취소했습니다."
        case .noData:
            return "데이터가 없습니다."
        }
    }
}

protocol AuthServiceProtocol {
    func registerUser(name: String, email: String, password: String) -> Observable<TokenData>
    func login(email: String, password: String) -> Observable<TokenData>
    func verifyEmail(email: String, code: String) -> Observable<Bool>
    func resendVerificationCode(email: String) -> Observable<Bool>
    func forgotPassword(email: String) -> Observable<Bool>
    func verifyResetCode(email: String, code: String) -> Observable<Bool>
    func resetPassword(email: String, code: String, password: String) -> Observable<TokenData>
    func logout() -> Observable<Bool>
    func deleteAccount() -> Observable<Bool>
    
    func refreshToken() -> Observable<String>
    
    func handleSocialLogin(from viewController: UIViewController, type: LoginType) -> Observable<User>
    func handleAppleLogin(from viewController: UIViewController) -> Observable<User>
    func handleDeepLink(_ url: URL) -> Observable<User>
}

class AuthService: NSObject, AuthServiceProtocol {
    static let shared = AuthService()
    
    private let apiClient = APIClient.shared
    private let tokenStorage = KeyChainTokenStorage.shared
    private let userManager = UserManager.shared
    private let disposeBag = DisposeBag()
    
    // 소셜 로그인 콜백
    private var socialLoginSubject: PublishSubject<User>?
    private var presentationContext: UIViewController?
    
    override init() {
        super.init()
    }
    
    func registerUser(name: String, email: String, password: String) -> Observable<TokenData> {
        return apiClient.request(APIEndpoint.register(name: name, email: email, password: password))
            .map { (response: APIResponse<TokenData>) -> TokenData in
                guard let data = response.data else {
                    throw AuthError.noData
                }
                
                // save tokens
                self.tokenStorage.saveTokens(
                    accessToken: data.accessToken,
                    refreshToken: data.refreshToken,
                    userId: data.user.id
                )
                
                // save user info
                self.userManager.setCurrentUser(data.user)
                
                return data
            }
            .catch { error in
                if let apiError = error as? NetworkError {
                    throw AuthError.apiError(apiError)
                }
                throw error
            }
    }
    
    func login(email: String, password: String) -> Observable<TokenData> {
        return apiClient.request(APIEndpoint.login(email: email, password: password))
            .map { (response: APIResponse<TokenData>) -> TokenData in
                guard let data = response.data else {
                    throw AuthError.noData
                }
                
                self.tokenStorage.saveTokens(
                    accessToken: data.accessToken,
                    refreshToken: data.refreshToken,
                    userId: data.user.id
                )
                
                self.userManager.setCurrentUser(data.user)
                
                return data
            }
            .catch { error -> Observable<TokenData> in
                if let apiError = error as? NetworkError {
                    return Observable.error(AuthError.apiError(apiError))
                }
                return Observable.error(error)
            }
    }
    
    
    func verifyEmail(email: String, code: String) -> Observable<Bool> {
        return apiClient.request(APIEndpoint.verifyEmail(email: email, code: code))
            .map { (response: APIResponse<Bool>) -> Bool in
                return response.success
            }
            .catch { error in
                if let apiError = error as? NetworkError {
                    throw AuthError.apiError(apiError)
                }
                throw error
            }
    }
    
    func resendVerificationCode(email: String) -> Observable<Bool> {
        return apiClient.request(APIEndpoint.resendVerificationCode(email: email))
            .map { (response: APIResponse<Bool>) -> Bool in
                return response.success
            }
            .catch { error in
                if let apiError = error as? NetworkError {
                    throw AuthError.apiError(apiError)
                }
                throw error
            }
    }
    
    func forgotPassword(email: String) -> Observable<Bool> {
        return apiClient.request(APIEndpoint.forgotPassword(email: email))
            .map { (response: APIResponse<Bool>) -> Bool in
                return response.success
            }
            .catch { error in
                if let apiError = error as? NetworkError {
                    throw AuthError.apiError(apiError)
                }
                throw error
            }
    }
    
    func verifyResetCode(email: String, code: String) -> Observable<Bool> {
        return apiClient.request(APIEndpoint.verifyResetCode(email: email, code: code))
            .map { (response: APIResponse<Bool>) -> Bool in
                return response.success
            }
            .catch { error in
                if let apiError = error as? NetworkError {
                    throw AuthError.apiError(apiError)
                }
                throw error
            }
    }
    
    func resetPassword(email: String, code: String, password: String) -> Observable<TokenData> {
        return apiClient.request(APIEndpoint.resetPassword(email: email, code: code, password: password))
            .map { (response: APIResponse<TokenData>) -> TokenData in
                guard let data = response.data else {
                    throw AuthError.noData
                }
                
                // 토큰 저장
                self.tokenStorage.saveTokens(
                    accessToken: data.accessToken,
                    refreshToken: data.refreshToken,
                    userId: data.user.id
                )
                
                // 사용자 정보 저장
                self.userManager.setCurrentUser(data.user)
                
                return data
            }
            .catch { error in
                if let apiError = error as? NetworkError {
                    throw AuthError.apiError(apiError)
                }
                throw error
            }
    }
    
    func logout() -> Observable<Bool> {
        return apiClient.request(APIEndpoint.logout)
            .map { (response: APIResponse<Bool>) -> Bool in
                // 토큰과 사용자 정보 삭제
                self.tokenStorage.clearTokens()
                self.userManager.clearCurrentUser()
                return response.success
            }
            .catch { error in
                // API 호출이 실패하더라도 로컬에서는 로그아웃 처리
                self.tokenStorage.clearTokens()
                self.userManager.clearCurrentUser()
                return .just(true)
            }
    }
    
    func deleteAccount() -> Observable<Bool> {
        return apiClient.request(APIEndpoint.deleteAccount)
            .map { (response: APIResponse<Bool>) -> Bool in
                // 계정 삭제 후 토큰과 사용자 정보 삭제
                self.tokenStorage.clearTokens()
                self.userManager.clearCurrentUser()
                return response.success
            }
            .catch { error in
                if let apiError = error as? NetworkError {
                    throw AuthError.apiError(apiError)
                }
                throw error
            }
    }
    
    func refreshToken() -> Observable<String> {
        guard let refreshToken = tokenStorage.refreshToken else {
            return Observable.error(AuthError.apiError(.unauthorized))
        }
        
        return apiClient.request(APIEndpoint.refreshToken(refreshToken: refreshToken))
            .map { (response: APIResponse<TokenData>) -> String in
                guard let data = response.data else {
                    throw AuthError.noData
                }
                
                // 새 액세스 토큰 저장
                self.tokenStorage.accessToken = data.accessToken
                return data.accessToken
            }
            .catch { error in
                if let apiError = error as? NetworkError {
                    throw AuthError.apiError(apiError)
                }
                throw error
            }
    }
    
    func handleSocialLogin(from viewController: UIViewController, type: LoginType) -> Observable<User> {
        let subject = PublishSubject<User>()
        self.socialLoginSubject = subject
        self.presentationContext = viewController
        
        var endPoint: APIEndpoint
        
        switch type {
        case .google: endPoint = .googleLogin
        case .kakao: endPoint = .kakaoLogin
        case .naver: endPoint = .naverLogin
        default:
            return Observable.error(AuthError.loginFailed)
        }
        
        guard let url = endPoint.url() else {
            return Observable.error(AuthError.apiError(.invalidURL))
        }
        
        // ASWebAuthenticationSession을 사용
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "packingapp"
        ) { callbackURL, error in
            if let error = error {
                subject.onError(AuthError.loginFailed)
                return
            }
            
            guard let callbackURL = callbackURL else {
                subject.onError(AuthError.loginFailed)
                return
            }
            
            // 딥링크 처리
            _ = self.handleDeepLink(callbackURL)
                .subscribe(onNext: { user in
                    subject.onNext(user)
                    subject.onCompleted()
                }, onError: { error in
                    subject.onError(error)
                })
        }
        
        // 프레젠테이션 컨텍스트 제공
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = false
        
        // 웹 인증 세션 시작
        session.start()
        
        return subject.asObservable()
    }
    
    
    // Apple 로그인 처리
    func handleAppleLogin(from viewController: UIViewController) -> Observable<User> {
        let subject = PublishSubject<User>()
        self.socialLoginSubject = subject
        self.presentationContext = viewController
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        return subject.asObservable()
    }
    
    // 딥링크 처리 (소셜 로그인 콜백)
    func handleDeepLink(_ url: URL) -> Observable<User> {
        // URL에서 토큰 추출
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems,
              let accessToken = queryItems.first(where: { $0.name == "accessToken" })?.value,
              let refreshToken = queryItems.first(where: { $0.name == "refreshToken" })?.value,
              let userId = queryItems.first(where: { $0.name == "userId" })?.value else {
            return Observable.error(AuthError.loginFailed)
        }
        
        // 토큰 저장
        self.tokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userId: userId
        )
        
        // 사용자 정보 가져오기
        return self.getUserInfo()
    }
    
    // 사용자 정보 가져오기
    private func getUserInfo() -> Observable<User> {
        return apiClient.request(APIEndpoint.getMyProfile)
            .map { (response: APIResponse<UserResponse>) -> User in
                guard let data = response.data else {
                    throw AuthError.noData
                }
                
                // 사용자 정보 저장
                self.userManager.setCurrentUser(data.user)
                
                return data.user
            }
            .catch { error in
                if let apiError = error as? NetworkError {
                    throw AuthError.apiError(apiError)
                }
                throw error
            }
    }
}

extension AuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            var email: String?
            var fullName: PersonNameComponents? = appleIDCredential.fullName
            
            // Apple은 처음 로그인할 때만 이메일과 이름을 제공
            if let appleEmail = appleIDCredential.email {
                email = appleEmail
            }
            
            // Apple 로그인 검증 요청
            _ = apiClient.request(APIEndpoint.appleVerify(userId: userId, email: email, fullName: fullName))
                .subscribe(onNext: { [weak self] (response: APIResponse<TokenData>) in
                    guard let self = self, let data = response.data else {
                        self?.socialLoginSubject?.onError(AuthError.noData)
                        return
                    }
                    
                    // 토큰 저장
                    self.tokenStorage.saveTokens(
                        accessToken: data.accessToken,
                        refreshToken: data.refreshToken,
                        userId: data.user.id
                    )
                    
                    // 사용자 정보 저장
                    self.userManager.setCurrentUser(data.user)
                    
                    self.socialLoginSubject?.onNext(data.user)
                    self.socialLoginSubject?.onCompleted()
                }, onError: { [weak self] error in
                    if let networkError = error as? NetworkError {
                        self?.socialLoginSubject?.onError(AuthError.apiError(networkError))
                    } else {
                        self?.socialLoginSubject?.onError(error)
                    }
                })
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        socialLoginSubject?.onError(AuthError.userCancelled)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presentationContext?.view.window ?? UIWindow()
    }
}

extension AuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return presentationContext?.view.window ?? UIWindow()
    }
}
