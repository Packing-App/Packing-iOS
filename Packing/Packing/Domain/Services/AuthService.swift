//
//  AuthService.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import RxSwift
import AuthenticationServices

protocol AuthServiceProtocol {
    func initiateOAuthLogin(type: LoginType) -> Observable<URL>
    func handleCallback(url: URL) -> Observable<AuthResult>
    func loginWithApple(userId: String, email: String?, fullName: PersonNameComponents?) -> Observable<AuthResult>
//    func refreshToken() -> Observable<AuthResult>
//    func logout() -> Observable<Void>
}

struct AuthResult {
    let accessToken: String
    let refreshToken: String
    let userId: String
}

class AuthService: AuthServiceProtocol {
    private let apiClient: APIClient
    private let tokenStorage: TokenStorage
    
    init(apiClient: APIClient, tokenStorage: TokenStorage) {
        self.apiClient = apiClient
        self.tokenStorage = tokenStorage
    }
    
    func initiateOAuthLogin(type: LoginType) -> Observable<URL> {
        let endpoint: AuthEndpoint
        
        // initialize endpoint according to LoginType
        switch type {
        case .google: endpoint = .googleLogin
        case .kakao: endpoint = .kakaoLogin
        case .naver: endpoint = .naverLogin
        default:
            return Observable.error(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported LoginType"]))
        }
        
        guard let url = endpoint.url(with: apiClient.baseURL) else {
            return Observable.error(NetworkError.invalidURL)
        }
        
        // create single observable
        return Observable.just(url)
    }
    
    func handleCallback(url: URL) -> Observable<AuthResult> {
        return Observable.create { [weak self] observer in
            guard let self = self,
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let queryItems = components.queryItems else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            guard let accessToken = queryItems.first(where: { $0.name == "accessToken" })?.value,
                  let refreshToken = queryItems.first(where: { $0.name == "refreshToken" })?.value,
                  let userId = queryItems.first(where: { $0.name == "userId" })?.value else {
                observer.onError(NetworkError.invalidResponse)
                return Disposables.create()
            }
            
            // 토큰 저장
            self.tokenStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken, userId: userId)
            
            observer.onNext(AuthResult(accessToken: accessToken, refreshToken: refreshToken, userId: userId))
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func loginWithApple(userId: String, email: String?, fullName: PersonNameComponents?) -> Observable<AuthResult> {
        struct AppleResponse: Decodable {
            let success: Bool
            let accessToken: String
            let refreshToken: String
            let userId: String
        }
        return apiClient.request(endpoint: AuthEndpoint.appleLogin(userId: userId, email: email, fullName: fullName))
            .map { (response: AppleResponse) in
                // 토큰 저장
                self.tokenStorage.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    userId: response.userId
                )
                
                return AuthResult(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken,
                    userId: response.userId
                )
            }
    }
}

class SocialLoginService {
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func performOAuthLogin(for loginType: LoginType, from viewController: UIViewController) -> Observable<AuthResult> {
        return authService.initiateOAuthLogin(type: loginType)
            .flatMap { [weak viewController] url -> Observable<AuthResult> in
                guard let viewController = viewController else {
                    return Observable.error(NSError(domain: "SocialLoginService", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewController is nil"]))
                }
                
                return Observable.create { observer in
                    let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "packingapp") { callbackURL, error in
                        if let error = error {
                            observer.onError(error)
                            return
                        }
                        
                        guard let callbackURL = callbackURL else {
                            observer.onError(NetworkError.invalidResponse)
                            return
                        }
                        
                        self.authService.handleCallback(url: callbackURL)
                            .subscribe(
                                onNext: { authResult in
                                    observer.onNext(authResult)
                                    observer.onCompleted()
                                },
                                onError: { error in
                                    observer.onError(error)
                                }
                            )
                            .disposed(by: DisposeBag())
                    }
                    
                    session.presentationContextProvider = viewController as? ASWebAuthenticationPresentationContextProviding
                    session.prefersEphemeralWebBrowserSession = false
                    
                    if !session.start() {
                        observer.onError(NSError(domain: "SocialLoginService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to start authentication session"]))
                    }
                    
                    return Disposables.create {
                        // Cannot cancel ASWebAuthenticationSession once started
                    }
                }
            }
    }
    
    func performAppleLogin(from viewController: UIViewController) -> Observable<AuthResult> {
        return Observable.create { [weak viewController] observer in
            guard let viewController = viewController else {
                observer.onError(NSError(domain: "SocialLoginService", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewController is nil"]))
                return Disposables.create()
            }
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleAuthDelegate(
                onSuccess: { userId, email, fullName in
                    self.authService.loginWithApple(userId: userId, email: email, fullName: fullName)
                        .subscribe(
                            onNext: { authResult in
                                observer.onNext(authResult)
                                observer.onCompleted()
                            },
                            onError: { error in
                                observer.onError(error)
                            }
                        )
                        .disposed(by: DisposeBag())
                },
                onError: { error in
                    observer.onError(error)
                }
            )
            
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = viewController as? ASAuthorizationControllerPresentationContextProviding
            authorizationController.performRequests()
            
            return Disposables.create {
                // Cleanup if needed
            }
        }
    }
    
    // Apple 로그인 델리게이트를 위한 도우미 클래스
    private class AppleAuthDelegate: NSObject, ASAuthorizationControllerDelegate {
        private let onSuccess: (String, String?, PersonNameComponents?) -> Void
        private let onError: (Error) -> Void
        
        init(onSuccess: @escaping (String, String?, PersonNameComponents?) -> Void, onError: @escaping (Error) -> Void) {
            self.onSuccess = onSuccess
            self.onError = onError
            super.init()
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                let email = appleIDCredential.email
                let fullName = appleIDCredential.fullName
                
                onSuccess(userId, email, fullName)
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            onError(error)
        }
    }
}
