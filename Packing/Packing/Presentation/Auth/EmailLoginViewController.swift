//
//  EmailLoginViewController.swift
//  Packing
//
//  Created by 이융의 on 3/31/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class EmailLoginViewController: UIViewController, StoryboardView {
    
    // MARK: - PROPERTIES
    var disposeBag = DisposeBag()
    
    // MARK: - UI COMPONENTS
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logoIcon"))
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일"
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var logInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyStyle(MainButtonStyle(color: .main))
        button.configuration?.title = "로그인"
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyStyle(MainButtonStyle(color: .black))
        button.configuration?.title = "회원가입"
        return button
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 24
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "이메일 로그인"
        self.view.backgroundColor = .systemBackground
        
        setupUI()
        setupKeyboardDismissGesture()
    }
    
    // MARK: - SETUP
    
    private func setupUI() {
        // addSubViews
        view.addSubview(logoImageView)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(logInButton)
        view.addSubview(signUpButton)
        view.addSubview(loadingIndicator)
        
        // constraint
        NSLayoutConstraint.activate([
            // 로고 이미지
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            
            // 이메일 텍스트필드
            emailTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // 비밀번호 텍스트필드
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // 로그인 버튼
            logInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 회원가입 버튼
            signUpButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 24),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 로딩 인디케이터
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - ACTIONS
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Binding
    
    func bind(reactor: EmailLoginReactor) {
        // Action
        emailTextField.rx.text.orEmpty
            .map { Reactor.Action.updateEmail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .map { Reactor.Action.updatePassword($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        logInButton.rx.tap
            .map { Reactor.Action.login }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .map { Reactor.Action.goToSignUp }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.isLoginEnabled }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isEnabled in
                self?.logInButton.isEnabled = isEnabled
                self?.logInButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.logInButton.isEnabled = false
                    self?.signUpButton.isEnabled = false
                    self?.emailTextField.isEnabled = false
                    self?.passwordTextField.isEnabled = false
                } else {
                    self?.loadingIndicator.stopAnimating()
                    let isEnabled = reactor.currentState.isLoginEnabled
                    self?.logInButton.isEnabled = isEnabled
                    self?.logInButton.alpha = isEnabled ? 1.0 : 0.5
                    self?.signUpButton.isEnabled = true
                    self?.emailTextField.isEnabled = true
                    self?.passwordTextField.isEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.user }
            .distinctUntilChanged { $0?.id == $1?.id }
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] user in
                // 로그인 성공 후 MyPage로 이동
                guard let self = self else { return }
                
                let userService = UserService()
                let authService = AuthService.shared
                let myPageReactor = MyPageReactor(userService: userService, authService: authService)
                let myPageVC = MyPageViewController()
                myPageVC.reactor = myPageReactor
                
                // 루트 뷰 컨트롤러로 설정 (로그인 스택 제거)
                let navigationController = UINavigationController(rootViewController: myPageVC)
                navigationController.isNavigationBarHidden = false
                UIApplication.shared.windows.first?.rootViewController = navigationController
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.error }
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] error in
                // 오류 메시지 표시
                let alert = UIAlertController(
                    title: "로그인 오류",
                    message: error?.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isNavigatingToSignUp }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                // 회원가입 화면으로 이동
                let authService = AuthService.shared
                let signUpReactor = EmailSignUpReactor()
                let signUpVC = EmailSignUpViewController()
                signUpVC.reactor = signUpReactor
                
                self?.navigationController?.pushViewController(signUpVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

#Preview {
    EmailLoginViewController()
}
