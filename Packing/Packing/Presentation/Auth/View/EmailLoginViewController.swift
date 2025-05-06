//
//  EmailLoginViewController.swift
//  Packing
//
//  Created by 이융의 on 3/31/25.
//

import UIKit
import RxSwift
import RxCocoa

class EmailLoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: EmailLoginViewModel
    private let deviceService: DeviceServiceProtocol = DeviceService()

    private let disposeBag = DisposeBag()
    
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
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(viewModel: EmailLoginViewModel = EmailLoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "이메일 로그인"
        self.view.backgroundColor = .systemBackground
        
        setupUI()
        setupKeyboardDismissGesture()
        bindViewModel()
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
    
    private func bindViewModel() {
        // 입력 바인딩
        let input = EmailLoginViewModel.Input(
            email: emailTextField.rx.text.orEmpty.asObservable(),
            password: passwordTextField.rx.text.orEmpty.asObservable(),
            loginTap: logInButton.rx.tap.asObservable(),
            signUpTap: signUpButton.rx.tap.asObservable()
        )
        
        // 출력 바인딩
        let output = viewModel.transform(input: input)
        
        // 로그인 버튼 활성화 상태 바인딩
        output.isLoginEnabled
            .drive(logInButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 로딩 상태 바인딩
        output.isLoading
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 버튼 활성화/비활성화 상태에 따른 alpha 값 조정
        output.isLoginEnabled
            .map { $0 ? 1.0 : 0.5 }
            .drive(logInButton.rx.alpha)
            .disposed(by: disposeBag)
        
        // 로그인 결과 바인딩
        output.loginResult
            .drive(onNext: { [weak self] result in
                switch result {
                case .success:
                    // 임시 저장된 디바이스 토큰이 있다면 서버에 등록
                    if let token = UserDefaults.standard.string(forKey: "tempDeviceToken") {
                        self?.registerDeviceToken(token)
                    }
                    
                    // 로그인 컨텍스트 확인 - 여행 생성에서 왔는지 체크
                    if UserDefaults.standard.bool(forKey: "isLoginFromJourneyCreation") {
                        // 여행 생성 플로우로 돌아가기
                        self?.continueJourneyCreation()
                    } else {
                        // 일반 로그인 - 메인 화면으로 이동
                        self?.navigateToMainScreen()
                    }
                case .failure:
                    // 에러는 errorMessage에서 처리
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // 회원가입 화면 이동 바인딩
        output.showSignUp
            .drive(onNext: { [weak self] in
                self?.navigateToSignUp()
            })
            .disposed(by: disposeBag)
        
        // 에러 메시지 바인딩
        output.errorMessage
            .drive(onNext: { [weak self] message in
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Methods

    private func navigateToMainScreen() {
        AuthCoordinator.shared.showMainScreen()
    }
    
    private func navigateToSignUp() {
        let signUpViewModel = EmailSignUpViewModel()
        let signUpViewController = EmailSignUpViewController(viewModel: signUpViewModel)
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func registerDeviceToken(_ token: String) {
        deviceService.updateDeviceToken(token: token)
            .subscribe(onNext: { success in
                print("로그인 후 디바이스 토큰 등록 성공: \(success)")
                // 등록 성공하면 임시 토큰 삭제
                if success {
                    UserDefaults.standard.removeObject(forKey: "tempDeviceToken")
                }
            })
            .disposed(by: disposeBag)
    }

    // 게스트 모드 시작 메서드 추가
    private func startGuestMode() {
        // AuthCoordinator를 통해 게스트 모드 여행 생성 시작
        AuthCoordinator.shared.startGuestJourneyCreation(from: self.navigationController)
    }
    // 여행 생성으로 돌아가는 메서드 추가
    private func continueJourneyCreation() {
        // AuthCoordinator를 통해 여행 생성 플로우로 돌아가기
        AuthCoordinator.shared.continueJourneyCreationAfterLogin()
    }
    
    // MARK: - ACTIONS
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

#Preview {
    EmailLoginViewController()
}
