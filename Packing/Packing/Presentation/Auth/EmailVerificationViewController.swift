//
//  EmailVerificationViewController.swift
//  Packing
//
//  Created by 이융의 on 4/2/25.
//

/*
import UIKit

class EmailVerificationViewController: UIViewController {
    
    // MARK: - UI COMPONENTS
    // EMAIL VERIFICATION CODE SECTION
    
    private lazy var verificationHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
//        stack.alignment = .center
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
        button.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var verificationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "인증번호"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.delegate = self
        textField.tag = 4
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
    
    private lazy var verificationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(nextButtonTapped))
        button.isEnabled = false
        return button
    }()

    // MARK: - PROPERTIES
    
    private let userEmail: String
    private let userPassword: String
    private let userName: String
    
    private var isValidCode = false
    
    // MARK: - INIT
    
    init(email: String, password: String, userName: String) {
        self.userEmail = email
        self.userPassword = password
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
    }
    
    // 이 뷰 컨트롤러는 스토리보드가 아닌 코드로만 생성되도록
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = nextButton
        title = "이메일 인증"
        view.backgroundColor = .systemBackground
        
        verificationHeaderStack.addArrangedSubview(verificationLabel)
        verificationHeaderStack.addArrangedSubview(resendButton)
        
        verificationStackView.addArrangedSubview(verificationHeaderStack)
        verificationStackView.addArrangedSubview(verificationTextField)
        verificationStackView.addArrangedSubview(verificationErrorLabel)
        
        view.addSubview(verificationStackView)
        
        NSLayoutConstraint.activate([
            verificationStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            verificationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verificationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            verificationTextField.heightAnchor.constraint(equalToConstant: 48),
            resendButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }
        
    // MARK: - ACTIONS
    
    // Code Validation
    private func validateCode(code: String) -> Bool {
        // 간단한 검증: 6자리 숫자인지 확인
        let codeRegex = "^[0-9]{6}$"
        let codePredicate = NSPredicate(format: "SELF MATCHES %@", codeRegex)
        return codePredicate.evaluate(with: code)
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        print(#fileID, #function, #line, "- ")
        
        print(userEmail, userPassword, userName)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let code = textField.text, !code.isEmpty {
            isValidCode = validateCode(code: code)
            
            if code.isEmpty {
                verificationErrorLabel.isHidden = true
            } else if !isValidCode {
                verificationErrorLabel.text = "6자리 숫자를 입력해주세요."
                verificationErrorLabel.textColor = .systemRed
                verificationErrorLabel.isHidden = false
            } else {
                verificationErrorLabel.isHidden = true
            }
            
            nextButton.isEnabled = isValidCode
        }
    }
    
    @objc private func resendButtonTapped() {
        // 인증번호 재전송 로직
        print("인증번호 재전송 요청됨")
        
        // 재전송 버튼 일시적으로 비활성화
        resendButton.isEnabled = false
        
        // 애니메이션 효과와 함께 3초 후 다시 활성화
        UIView.animate(withDuration: 0.3) {
            self.resendButton.alpha = 0.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.resendButton.isEnabled = true
            UIView.animate(withDuration: 0.3) {
                self.resendButton.alpha = 1.0
            }
        }
        
        // 사용자에게 알림
        verificationErrorLabel.text = "인증번호가 재전송되었습니다."
        verificationErrorLabel.textColor = .systemBlue
        verificationErrorLabel.isHidden = false
        
        // 3초 후 알림 숨기기
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.verificationErrorLabel.textColor == .systemBlue {
                self.verificationErrorLabel.isHidden = true
            }
        }
    }
}


extension EmailVerificationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if nextButton.isEnabled {
            nextButtonTapped()
        }
        return true
    }
}

// MARK: - PREVIEW
#Preview {
    let viewController = EmailVerificationViewController(email: "123", password: "123", userName: "123")
    let navigationController = UINavigationController(rootViewController: viewController)
    return navigationController
}

*/

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class EmailVerificationViewController: UIViewController, StoryboardView {
    
    // MARK: - PROPERTIES
    var disposeBag = DisposeBag()
    
    private let userEmail: String
    private let userPassword: String
    private let userName: String
    
    // MARK: - UI COMPONENTS
    // EMAIL VERIFICATION CODE SECTION
    
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
        textField.tag = 4
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
    
    private lazy var verificationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)
        button.isEnabled = false
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - INIT
    
    init(email: String, password: String, userName: String) {
        self.userEmail = email
        self.userPassword = password
        self.userName = userName
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
    }
    
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = nextButton
        title = "이메일 인증"
        view.backgroundColor = .systemBackground
        
        verificationHeaderStack.addArrangedSubview(verificationLabel)
        verificationHeaderStack.addArrangedSubview(resendButton)
        
        verificationStackView.addArrangedSubview(verificationHeaderStack)
        verificationStackView.addArrangedSubview(verificationTextField)
        verificationStackView.addArrangedSubview(verificationErrorLabel)
        
        view.addSubview(verificationStackView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            verificationStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            verificationStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verificationStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            verificationTextField.heightAnchor.constraint(equalToConstant: 48),
            resendButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Binding
    
    func bind(reactor: EmailVerificationReactor) {
        // Action
        verificationTextField.rx.text.orEmpty
            .map { Reactor.Action.updateCode($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .map { Reactor.Action.verifyCode }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        resendButton.rx.tap
            .map { Reactor.Action.resendCode }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.isCodeValid }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isValid in
                self?.nextButton.isEnabled = isValid
                if let code = self?.verificationTextField.text, !code.isEmpty {
                    self?.verificationErrorLabel.isHidden = isValid
                } else {
                    self?.verificationErrorLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.codeErrorMessage }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] message in
                self?.verificationErrorLabel.text = message
                if message == "인증번호가 재전송되었습니다." {
                    self?.verificationErrorLabel.textColor = .systemBlue
                    self?.verificationErrorLabel.isHidden = false
                    
                    // 3초 후 알림 숨기기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        if self?.verificationErrorLabel.textColor == .systemBlue {
                            self?.verificationErrorLabel.isHidden = true
                        }
                    }
                } else {
                    self?.verificationErrorLabel.textColor = .systemRed
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.nextButton.isEnabled = false
                    self?.resendButton.isEnabled = false
                    self?.verificationTextField.isEnabled = false
                } else {
                    self?.loadingIndicator.stopAnimating()
                    let isCodeValid = reactor.currentState.isCodeValid
                    self?.nextButton.isEnabled = isCodeValid
                    self?.resendButton.isEnabled = true
                    self?.verificationTextField.isEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isResendComplete }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                // 재전송 버튼 일시적으로 비활성화
                self?.resendButton.isEnabled = false
                
                // 애니메이션 효과와 함께 3초 후 다시 활성화
                UIView.animate(withDuration: 0.3) {
                    self?.resendButton.alpha = 0.5
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.resendButton.isEnabled = true
                    UIView.animate(withDuration: 0.3) {
                        self?.resendButton.alpha = 1.0
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isVerificationComplete }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                // 이메일 인증 완료 후, 회원가입 진행
                self?.nextButton.isEnabled = false
                reactor.action.onNext(.register)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.user }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] user in
                // 회원가입 완료 후 MyPage로 이동
                guard let self = self else { return }
                
                // 완료 알림 표시
                let alert = UIAlertController(
                    title: "회원가입 완료",
                    message: "환영합니다! 회원가입이 정상적으로 완료되었습니다.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                    // MyPage로 이동
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
                
                self.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.error }
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] error in
                // 오류 메시지 표시
                let alert = UIAlertController(
                    title: "오류",
                    message: error?.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension EmailVerificationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if nextButton.isEnabled {
//            nextButton.rx.tap.onNext(())
        }
        return true
    }
}
