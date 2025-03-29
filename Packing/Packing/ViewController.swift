//
//  ViewController.swift
//  Packing
//
//  Created by 이융의 on 3/24/25.
//

import UIKit
import WebKit
import AuthenticationServices   // for apple login

class ViewController: UIViewController {
    
    // MARK: - UI Layouts
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var googleLoginButton: UIButton = {
        createSocialLoginButton(title: "Google Login", color: .gray)
    }()
    private lazy var kakaoLoginButton: UIButton = {
        createSocialLoginButton(title: "Kakao Login", color: .yellow)
    }()
    private lazy var naverLoginButton: UIButton = {
        createSocialLoginButton(title: "Naver Login", color: .green)
    }()
    
    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        return button
    }()
    
//    private var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupButtonActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(googleLoginButton)
        stackView.addArrangedSubview(kakaoLoginButton)
        stackView.addArrangedSubview(naverLoginButton)
        stackView.addArrangedSubview(appleLoginButton)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 250),
            
            googleLoginButton.heightAnchor.constraint(equalToConstant: 50),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 50),
            naverLoginButton.heightAnchor.constraint(equalToConstant: 50),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    // MARK: - Login Button UI
    private func createSocialLoginButton(title: String, color: UIColor) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = color
        config.baseForegroundColor = .black
        config.title = title
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupButtonActions() {
        googleLoginButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
        naverLoginButton.addTarget(self, action: #selector(handleNaverLogin), for: .touchUpInside)
    }
    
    @objc private func handleGoogleLogin() {
        print(#fileID, #function, #line, "- ")
        performOAuthLogin(for: .googleLogin)
    }
    @objc private func handleKakaoLogin() {
        performOAuthLogin(for: .kakaoLogin)
    }
    @objc private func handleNaverLogin() {
        performOAuthLogin(for: .naverLogin)
    }
    
    @objc private func handleAppleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func performOAuthLogin(for route: AuthRoute) {
        print(#fileID, #function, #line, "- ")
        NetworkManager.shared.initiateOAuthLogin(route: route) { [weak self]result in
            switch result {
            case .success(let url):
//                self?.presentWebView(with: url)   --> WebView 로 직접 소통하려고 하니 google security 정책으로 인해 403 user agent 오류가 뜸.
                // -> 백엔드를 통해서 Oauth에 인증
                // 여기서는 ASWebAuthenticationSession 를 통해 handleAuthCallback으로 토큰을 여기서 받으면 됨.
                self?.startAuthenticationSession(with: url)
            case .failure(let error):
                print("로그인 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func startAuthenticationSession(with url: URL) {
        print(#fileID, #function, #line, "- ")
        let session = ASWebAuthenticationSession(url: url, callback: .customScheme("packingapp")) { [weak self] url, err in
            if let err = err {
                print("Authentication error: \(err.localizedDescription)")
                return
            }
            guard let callbackURL = url else {
                print("callBackURL is nil")
                return
            }
            self?.handleAuthCallback(url: callbackURL)
        }
        
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = false // 로그인 상태 유지 필요시 false
        session.start()
    }
    private func handleAuthCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return
        }
        
        let accessToken = components.queryItems?.first(where: { $0.name == "accessToken"})?.value
        let refreshToken = components.queryItems?.first(where: { $0.name == "refreshToken"})?.value
        let userId = components.queryItems?.first(where: { $0.name == "userId"})?.value
        
        
        saveAuthTokens(accessToken: accessToken, refreshToken: refreshToken, userId: userId)
        
        // navigate to main view
    }
    
    
    private func saveAuthTokens(accessToken: String?, refreshToken: String?, userId: String?) {
        print("Access Token: \(accessToken ?? "N/A")")
        print("Refresh Token: \(refreshToken ?? "N/A")")
        print("User ID: \(userId ?? "N/A")")
    }
}


extension ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

// MARK: - APPLE LOGIN

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            NetworkManager.shared.sendAppleLoginCredentials(
                userId: userIdentifier,
                email: email,
                fullName: fullName
            ) { result in
                switch result {
                case .success:
                    print("Apple login credentials sent successfully")
                    // Handle successful Apple login
                case .failure(let error):
                    print("Apple login credential send failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("애플 로그인 실패: \(error.localizedDescription)")
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
