//
//  EmailSignUpViewController.swift
//  Packing
//
//  Created by 이융의 on 4/8/25.
//

import UIKit
import RxSwift
import RxCocoa

class EmailSignUpViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: EmailSignUpViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI COMPONENTS
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView(image: UIImage(named: "logoIcon"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillProportionally
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        return mainStackView
    }()
    
    // MARK: - Email Section
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일을 입력하세요."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일 주소"
        textField.keyboardType = .emailAddress
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.tag = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var emailErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Password Section
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호를 입력하세요."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "영문, 숫자를 조합한 8~20 글자"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.tag = 1
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Password Confirm Section
    private lazy var confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호를 다시 입력하세요."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호 확인"
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = true
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.tag = 2
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var confirmPasswordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmPasswordStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Name Section
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름(별명)을 입력하세요."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "사용할 이름(별명)"
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.tag = 3
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var nameErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Next Button Section
    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "다음", style: .done, target: nil, action: nil)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Loading Indicator
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(viewModel: EmailSignUpViewModel = EmailSignUpViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        bindViewModel()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        self.navigationItem.title = "회원가입"
        self.navigationItem.rightBarButtonItem = nextButton
        
        view.backgroundColor = .systemBackground
        
        // Setup scrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add content to contentView
        contentView.addSubview(logoImageView)
        contentView.addSubview(mainStackView)
        contentView.addSubview(loadingIndicator)
        
        // Setup email Section
        emailStackView.addArrangedSubview(emailLabel)
        emailStackView.addArrangedSubview(emailTextField)
        emailStackView.addArrangedSubview(emailErrorLabel)
        
        // Setup password section
        passwordStackView.addArrangedSubview(passwordLabel)
        passwordStackView.addArrangedSubview(passwordTextField)
        passwordStackView.addArrangedSubview(passwordErrorLabel)
        
        // Setup confirm password section
        confirmPasswordStackView.addArrangedSubview(confirmPasswordLabel)
        confirmPasswordStackView.addArrangedSubview(confirmPasswordTextField)
        confirmPasswordStackView.addArrangedSubview(confirmPasswordErrorLabel)
        
        // Setup Name Section
        nameStackView.addArrangedSubview(nameLabel)
        nameStackView.addArrangedSubview(nameTextField)
        nameStackView.addArrangedSubview(nameErrorLabel)
        
        // Add sections to main stack View
        [emailStackView, passwordStackView, confirmPasswordStackView, nameStackView].forEach { stack in
            mainStackView.addArrangedSubview(stack)
        }
        
        // Constraints
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Logo
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            
            // Main Stack View
            mainStackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // TextFields (height)
            emailTextField.heightAnchor.constraint(equalToConstant: 48),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 48),
            nameTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardSize.height
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        // Input
        let input = EmailSignUpViewModel.Input(
            email: emailTextField.rx.text.orEmpty.asObservable(),
            password: passwordTextField.rx.text.orEmpty.asObservable(),
            confirmPassword: confirmPasswordTextField.rx.text.orEmpty.asObservable(),
            name: nameTextField.rx.text.orEmpty.asObservable(),
            nextButtonTap: nextButtonTap.asObservable()
        )
        
        // Output
        let output = viewModel.transform(input: input)
        
        // 이메일 유효성 바인딩
        output.isEmailValid
            .drive(onNext: { [weak self] isValid in
                self?.emailErrorLabel.isHidden = isValid || self?.emailTextField.text?.isEmpty ?? true
            })
            .disposed(by: disposeBag)
        
        output.emailErrorMessage
            .drive(emailErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 비밀번호 유효성 바인딩
        output.isPasswordValid
            .drive(onNext: { [weak self] isValid in
                self?.passwordErrorLabel.isHidden = isValid || self?.passwordTextField.text?.isEmpty ?? true
            })
            .disposed(by: disposeBag)
        
        output.passwordErrorMessage
            .drive(passwordErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 비밀번호 확인 유효성 바인딩
        output.isConfirmPasswordValid
            .drive(onNext: { [weak self] isValid in
                self?.confirmPasswordErrorLabel.isHidden = isValid || self?.confirmPasswordTextField.text?.isEmpty ?? true
            })
            .disposed(by: disposeBag)
        
        output.confirmPasswordErrorMessage
            .drive(confirmPasswordErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 이름 유효성 바인딩
        output.isNameValid
            .drive(onNext: { [weak self] isValid in
                self?.nameErrorLabel.isHidden = isValid || self?.nameTextField.text?.isEmpty ?? true
            })
            .disposed(by: disposeBag)
        
        output.nameErrorMessage
            .drive(nameErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 다음 버튼 활성화 상태 바인딩
        output.isNextButtonEnabled
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 로딩 상태 바인딩
        output.isLoading
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 에러 메시지 바인딩
        output.errorMessage
            .drive(onNext: { [weak self] message in
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        // 회원가입 성공 시 이메일 인증 화면으로 이동
        output.registerSuccess
            .drive(onNext: { [weak self] (email, password, name, tokenData) in
                self?.navigateToEmailVerification(
                    email: email,
                    password: password,
                    name: name,
                    tokenData: tokenData
                )
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation
    
    private func navigateToEmailVerification(email: String, password: String, name: String, tokenData: TokenData) {
        let verificationViewModel = EmailVerificationViewModel(
            email: email,
            password: password,
            name: name,
            tokenData: tokenData,
            authService: viewModel.authService
        )
        let verificationVC = EmailVerificationViewController(viewModel: verificationViewModel)
        navigationController?.pushViewController(verificationVC, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private let nextButtonTap = PublishRelay<Void>()
}

// MARK: - UITextFieldDelegate
extension EmailSignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0: passwordTextField.becomeFirstResponder()
        case 1: confirmPasswordTextField.becomeFirstResponder()
        case 2: nameTextField.becomeFirstResponder()
        case 3:
            textField.resignFirstResponder()
            if nextButton.isEnabled {
                nextButtonTap.accept(())
            }
        default: textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - Preview
#Preview {
    let viewController = EmailSignUpViewController()
    let navigationController = UINavigationController(rootViewController: viewController)
    return navigationController
}
