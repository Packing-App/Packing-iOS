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
        createSocialLoginButton(title: "Google Login", color: .white)
    }()
    private lazy var kakaoLoginButton: UIButton = {
        createSocialLoginButton(title: "Kakao Login", color: .white)
    }()
    private lazy var naverLoginButton: UIButton = {
        createSocialLoginButton(title: "Naver Login", color: .white)
    }()
    
    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        return button
    }()
    
    private var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
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
        initiateOAuthLogin(for: .googleLogin)
    }
    @objc private func handleKakaoLogin() {
        initiateOAuthLogin(for: .googleLogin)
    }
    @objc private func handleNaverLogin() {
        initiateOAuthLogin(for: .googleLogin)
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
    
    private func initiateOAuthLogin(for route: AuthRoute) {
        NetworkManager.shared.initiateOAuthLogin(route: route) { [weak self] result in
            switch result {
            case .success(let url):
                self?.presentWebView(with: url)
            case .failure(let error):
                print("로그인 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func presentWebView(with url: URL) {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView?.navigationDelegate = self
        
        guard let webView = webView else { return }
        
        view.addSubview(webView)
        webView.load(URLRequest(url: url))
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping @MainActor (WKNavigationResponsePolicy) -> Void) {
        guard let httpResponse = navigationResponse.response as? HTTPURLResponse,
              let url = navigationResponse.response.url else {
            decisionHandler(.cancel)
            return
        }
        
        // MARK: - HANDLING DEEP LINK
        
        if url.scheme == "packing" && url.host == "auth" && url.path == "/callback" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let accessToken = components?.queryItems?.first(where: { $0.name == "accessToken"})?.value
            let refreshToken = components?.queryItems?.first(where: { $0.name == "refreshToken"})?.value
            let userId = components?.queryItems?.first(where: { $0.name == "userId"})?.value
            
            // TODO: Save Token in KeyChain
            saveAuthTokens(accessToken: accessToken, refreshToken: refreshToken, userId: userId)
            
            // navigate to main view
            decisionHandler(.cancel)
            webView.removeFromSuperview()
        } else {
            decisionHandler(.allow) //
        }
    }
    
    private func saveAuthTokens(accessToken: String?, refreshToken: String?, userId: String?) {
        print("Access Token: \(accessToken ?? "N/A")")
        print("Refresh Token: \(refreshToken ?? "N/A")")
        print("User ID: \(userId ?? "N/A")")
    }
}



// MARK: - APPLE LOGIN

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // MARK: - Send Apple login credentials to backend server
            print("Apple Login User ID: \(userIdentifier)")
            print("Name: \(fullName?.givenName ?? "N/A")")
            print("Email: \(email ?? "N/A")")
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
