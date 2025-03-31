////
////  SocialLoginManager.swift
////  Packing
////
////  Created by 이융의 on 3/30/25.
////
//
//import Foundation
//import RxSwift
//import AuthenticationServices
//
//protocol SocialLoginManager {
//    func initiateLogin(for loginType: LoginType) -> Observable<Result<URL, Error>>
//    func handleCallback(url: URL) -> Observable<Result<(accessToken: String, refreshToken: String, userId: String), Error>>
//    func handleAppleLogin(userId: String, email: String?, fullName: PersonNameComponents?) -> Observable<Result<User, Error>>
//}
//
//class DefaultSocialLoginManager: SocialLoginManager {
//    private let apiClient: APIClient
//    private let tokenStorage: TokenStorage
//    
//    init(apiClient: APIClient, tokenStorage: TokenStorage) {
//        self.apiClient = apiClient
//        self.tokenStorage = tokenStorage
//    }
//    
//    func initiateLogin(for loginType: LoginType) -> Observable<Result<URL, Error>> {
//        let route: AuthRoute
//        
//        switch loginType {
//        case .google: route = .googleLogin
//        case .kakao: route = .kakaoLogin
//        case .naver: route = .naverLogin
//        case .apple: route = .appleLogin
//        case .email: return .just(.failure(NSError(domain: "SocialLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email login not supported"])))
//        }
//        
//        return apiClient.initiateOAuthURL(route: route)
//            .map { .success($0) }
//            .catch { .just(.failure($0)) }
//    }
//    
//    func handleCallback(url: URL) -> Observable<Result<(accessToken: String, refreshToken: String, userId: String), Error>> {
//        return Observable.create { observer in
//            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
//                  let queryItems = components.queryItems else {
//                observer.onNext(.failure(NSError(domain: "SocialLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid callback URL"])))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            let accessToken = queryItems.first(where: { $0.name == "accessToken" })?.value
//            let refreshToken = queryItems.first(where: { $0.name == "refreshToken" })?.value
//            let userId = queryItems.first(where: { $0.name == "userId" })?.value
//            
//            guard let accessToken = accessToken, let refreshToken = refreshToken, let userId = userId else {
//                observer.onNext(.failure(NSError(domain: "SocialLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing tokens in callback"])))
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            // Save tokens
//            self.tokenStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken, userId: userId)
//            
//            observer.onNext(.success((accessToken: accessToken, refreshToken: refreshToken, userId: userId)))
//            observer.onCompleted()
//            
//            return Disposables.create()
//        }
//    }
//    
//    func handleAppleLogin(userId: String, email: String?, fullName: PersonNameComponents?) -> Observable<Result<User, Error>> {
//        return Observable.create { observer in
//            let endpoint = AuthEndpoint.appleLogin(userId: userId, email: email, fullName: fullName)
//            
//            let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: "dummy")!)) { _, _, _ in
//                // This is a simplified version - you'd make a real API request
//                // Create a mock user since we don't have real API response parsing yet
//                let user = User(
////                    id: userId,
//                    name: [fullName?.givenName, fullName?.familyName].compactMap { $0 }.joined(separator: " "),
//                    email: email ?? "",
//                    profileImage: nil,
//                    socialType: .apple,
//                    socialId: userId
//                )
//                
//                observer.onNext(.success(user))
//                observer.onCompleted()
//            }
//            
//            task.resume()
//            
//            return Disposables.create {
//                task.cancel()
//            }
//        }
//    }
//}
