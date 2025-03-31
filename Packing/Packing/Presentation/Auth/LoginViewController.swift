//
//  LoginViewController.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import AuthenticationServices

//class LoginViewController: UIViewController, View {
//    typealias Reactor = LoginReactor
//    
//    var disposeBag = DisposeBag()
//    
//    // MARK: - UI Components
//    private lazy var stackView: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .vertical
//        stack.spacing = 20
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }()
//    
//    private lazy var socialLoginButtons: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .horizontal
//        stack.spacing = 8
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }()
//    
//    private lazy var logoImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "onboardingImage")
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "PACKING"
//        label.font = .preferredFont(forTextStyle: .headline)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private lazy var subtitleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "여행에 딱!\n필요한 짐만, 패킹"
//        label.font = .preferredFont(forTextStyle: .subheadline)
//        label.textColor = .secondaryLabel
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private lazy var googleLoginButton: UIButton = {
//        createSocialLoginButton("google")
//    }()
//    
//    private lazy var kakaoLoginButton: UIButton = {
//        createSocialLoginButton("kakao")
//    }()
//    
//    private lazy var naverLoginButton: UIButton = {
//        createSocialLoginButton("naver")
//    }()
//    
//    private lazy var appleLoginButton: UIButton = {
//        createSocialLoginButton("apple")
//    }()
//    
////    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
////        let button = ASAuthorizationAppleIDButton(type: .continue, style: .black)
////        button.translatesAutoresizingMaskIntoConstraints = false
////        return button
////    }()
//    
//    private lazy var loadingIndicator: UIActivityIndicatorView = {
//        let indicator = UIActivityIndicatorView(style: .large)
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        indicator.hidesWhenStopped = true
//        return indicator
//    }()
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//    }
//    
//    func bind(reactor: LoginReactor) {
//        // Action
//        googleLoginButton.rx.tap
//            .map { Reactor.Action.googleLogin }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//        
//        kakaoLoginButton.rx.tap
//            .map { Reactor.Action.kakaoLogin }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//        
//        naverLoginButton.rx.tap
//            .map { Reactor.Action.naverLogin }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//        
//        appleLoginButton.rx.controlEvent(.touchUpInside)
//            .subscribe (onNext: { [weak self] _ in
//                self?.handleAppleLogin()
//            })
//            .disposed(by: disposeBag)
//        
//        // State
//        reactor.state.map { $0.isLoading }
//            .distinctUntilChanged()
//            .bind(to: loadingIndicator.rx.isAnimating)
//            .disposed(by: disposeBag)
//        
//        reactor.state.map { $0.authResult }
//            .distinctUntilChanged{ $0?.userId == $1?.userId }
//            .subscribe(onNext: { [weak self] authResult in
//                if let authResult = authResult {
//                    print(#fileID, #function, #line, "- ")
//                    self?.handleSuccessfulLogin(authResult: authResult)
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        reactor.state.map { $0.error }
//           // ??
//            .filter { $0 != nil }
//            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
//            .subscribe (onNext: { error in
//                if let error = error {
//                    print(#fileID, #function, #line, "- ")
//                    print(error.localizedDescription)
////                    self?.reactor?.action.onError(error)
//                }
//            })
//            .disposed(by: disposeBag)
//    }
//    
//    // MARK: - UI Setup
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        
//        view.addSubview(stackView)
//        view.addSubview(loadingIndicator)
//        
//        stackView.addArrangedSubview(logoImageView)
//        stackView.addArrangedSubview(titleLabel)
//        stackView.addArrangedSubview(subtitleLabel)
//        stackView.setCustomSpacing(40, after: subtitleLabel)
//        stackView.addArrangedSubview(socialLoginButtons)
//        
//        socialLoginButtons.addArrangedSubview(googleLoginButton)
//        socialLoginButtons.addArrangedSubview(kakaoLoginButton)
//        socialLoginButtons.addArrangedSubview(naverLoginButton)
//        socialLoginButtons.addArrangedSubview(appleLoginButton)
//        
//        // TODO: constraints with snapkit
//        NSLayoutConstraint.activate([
//            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
//            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
//
//            logoImageView.heightAnchor.constraint(equalToConstant: 100),
//            
//            googleLoginButton.heightAnchor.constraint(equalToConstant: 24),
//            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 24),
//            naverLoginButton.heightAnchor.constraint(equalToConstant: 24),
//            appleLoginButton.heightAnchor.constraint(equalToConstant: 24),
//            
//            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    private func createSocialLoginButton(_ type: String) -> UIButton {
//        let button = UIButton()
//        button.setImage(UIImage(named: type), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }
//    
//    private func handleSuccessfulLogin(authResult: AuthResult) {
//        // navigate to main viewcontroller
//        // coordinator pattern OR scenedelegate 에서 rootViewController 변경
//        print(#fileID, #function, #line, "- ")
//        print("Login Success: \(authResult.userId)")
//        
////        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
////            sceneDelegate.showMainScreen()
////        }
//    }
//    
//    private func handleAppleLogin() {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
//}
//
//// MARK: - APPLE LOGIN
//extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return view.window!
//    }
//}
//
//// MARK: - ASWebAuthenticationPresentationContextProviding
//extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        return view.window!
//    }
//}



// MARK: - UI VIEW

class LoginViewController: UIViewController {
    
    // MARK: - UI COMPONENTS
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var socialLoginButtons: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "onboardingImage")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "여행에 딱! \n필요한 짐만, 패킹"
        label.font = UIFont.systemFont(ofSize: 23, weight: .black)
        label.textAlignment = .center
        
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginPromptLabel: UIView = {
        let label = UILabel()
        
        // Image Attachment
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "logoIcon")
        
        let fontCapHeight = label.font.capHeight
        let yOffset = (fontCapHeight - 20.0) / 2  // 이미지 높이(20)와 폰트 높이 차이의 절반만큼 조정
        
        imageAttachment.bounds = CGRect(x: 0, y: yOffset, width: 15, height: 15)
        
        // 현재 텍스트와 이미지 결합
        let attributedString = NSMutableAttributedString(string: "3초만에 시작하기  ")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        label.attributedText = attributedString
        label.sizeToFit()
        
        // 레이블 설정
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // border
        containerView.layer.borderWidth = 0.8
        containerView.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.3
        
        return containerView
    }()
    
    private lazy var emailLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyStyle(MainButtonStyle(color: .main))
        button.configuration?.title = "이메일로 로그인"
        button.addTarget(self, action: #selector(didTapEmailLoginButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var googleLoginButton: UIButton = {
        createSocialLoginButton("google")
    }()
    
    private lazy var kakaoLoginButton: UIButton = {
        createSocialLoginButton("kakao")
    }()
    
    private lazy var naverLoginButton: UIButton = {
        createSocialLoginButton("naver")
    }()
    
    private lazy var appleLoginButton: UIButton = {
        createSocialLoginButton("apple")
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.navigationItem.title = "PACKING"
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        view.addSubview(socialLoginButtons)
        view.addSubview(loadingIndicator)
        view.addSubview(emailLoginButton)
        
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.setCustomSpacing(80, after: subtitleLabel)
        stackView.addArrangedSubview(loginPromptLabel)
        
        socialLoginButtons.addArrangedSubview(googleLoginButton)
        socialLoginButtons.addArrangedSubview(kakaoLoginButton)
        socialLoginButtons.addArrangedSubview(naverLoginButton)
        socialLoginButtons.addArrangedSubview(appleLoginButton)
        
        // TODO: constraints with snapkit
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            
            socialLoginButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            socialLoginButtons.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 70),
            socialLoginButtons.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70),
            socialLoginButtons.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            
            emailLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLoginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 70),
            emailLoginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70),
            emailLoginButton.heightAnchor.constraint(equalToConstant: 50),
            emailLoginButton.topAnchor.constraint(equalTo: socialLoginButtons.bottomAnchor, constant: 30),
            
            
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func createSocialLoginButton(_ type: String) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: type), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc private func didTapEmailLoginButton(_ sender: UIButton) {
        print(#fileID, #function, #line, "- ")
        
        let emailLoginVC = EmailLoginViewController()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(emailLoginVC, animated: true)
        
        
    }
}




#Preview {
    UINavigationController(rootViewController: LoginViewController())
}
