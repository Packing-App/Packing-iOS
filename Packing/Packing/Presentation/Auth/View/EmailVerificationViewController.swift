//
//  EmailVerificationViewController.swift
//  Packing
//
//  Created by 이융의 on 4/8/25.
//

import UIKit
import RxSwift
import RxCocoa

class EmailVerificationViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: EmailVerificationViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI COMPONENTS
    
    private lazy var verificationHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var verificationLabel: UILabel = {
        let label = UILabel()
        label.text = "인증번호를 입력하세요."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("재전송", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var verificationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "인증번호"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var verificationErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var verificationStatusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var verificationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var completeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)
        button.isEnabled = false
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    
    init(viewModel: EmailVerificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        bindViewModel()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = completeButton
        title = "이메일 인증"
        view.backgroundColor = .systemBackground
        
        verificationHeaderStack.addArrangedSubview(verificationLabel)
        verificationHeaderStack.addArrangedSubview(resendButton)
        
        verificationStackView.addArrangedSubview(verificationHeaderStack)
        verificationStackView.addArrangedSubview(verificationTextField)
        verificationStackView.addArrangedSubview(verificationErrorLabel)
        verificationStackView.addArrangedSubview(verificationStatusLabel)
        
        view.addSubview(verificationStackView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            verificationStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            verificationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verificationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            verificationTextField.heightAnchor.constraint(equalToConstant: 48),
            resendButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        // Input
        let input = EmailVerificationViewModel.Input(
            verificationCode: verificationTextField.rx.text.orEmpty.asObservable(),
            resendButtonTap: resendButton.rx.tap.asObservable(),
            completeButtonTap: completeButton.rx.tap.asObservable()
        )
        
        // Output
        let output = viewModel.transform(input: input)
        
        // 인증 코드 유효성 바인딩
        output.isCodeValid
            .drive(onNext: { [weak self] isValid in
                self?.verificationErrorLabel.isHidden = isValid || self?.verificationTextField.text?.isEmpty ?? true
            })
            .disposed(by: disposeBag)
        
        output.codeErrorMessage
            .drive(verificationErrorLabel.rx.text)
            .disposed(by: disposeBag)
        
        // 완료 버튼 활성화 상태 바인딩
        output.isCompleteButtonEnabled
            .drive(completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 로딩 상태 바인딩
        output.isLoading
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 인증 메시지 바인딩
        output.verificationMessage
            .drive(onNext: { [weak self] message in
                self?.verificationStatusLabel.text = message
                self?.verificationStatusLabel.isHidden = message == nil
            })
            .disposed(by: disposeBag)
        
        // 재전송 버튼 활성화 상태 바인딩
        output.resendButtonEnabled
            .drive(resendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.resendButtonEnabled
            .map { $0 ? 1.0 : 0.5 }
            .drive(resendButton.rx.alpha)
            .disposed(by: disposeBag)
        
        // 회원가입 결과 바인딩
        output.signUpResult
            .drive(onNext: { [weak self] result in
                switch result {
                case .success(let user):
                    self?.showSignUpSuccessAlert(user: user)
                case .failure:
                    // 에러는 errorMessage에서 처리
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // 에러 메시지 바인딩
        output.errorMessage
            .drive(onNext: { [weak self] message in
                self?.showAlert(title: "오류", message: message)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Methods
    
    private func showSignUpSuccessAlert(user: User) {
        let alert = UIAlertController(
            title: "회원가입 성공",
            message: "\(user.name)님, 회원가입이 완료되었습니다!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigateToMainScreen()
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToMainScreen() {
        // 회원가입 완료 후 메인 화면으로 이동
        // 여기에 메인 화면 이동 코드 추가
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

private let completeButtonTap = PublishRelay<Void>()

// MARK: - UITextFieldDelegate
extension EmailVerificationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if completeButton.isEnabled {
            completeButtonTap.accept(())
        }
        return true
    }
}

// MARK: - Preview
#Preview {
    let viewModel = EmailVerificationViewModel(
        email: "test@example.com",
        password: "password123",
        name: "테스트 사용자",
        tokenData: TokenData(
            accessToken: "test_token",
            refreshToken: "test_refresh_token",
            user: User.exampleUser
        )
    )
    let viewController = EmailVerificationViewController(viewModel: viewModel)
    let navigationController = UINavigationController(rootViewController: viewController)
    return navigationController
}
