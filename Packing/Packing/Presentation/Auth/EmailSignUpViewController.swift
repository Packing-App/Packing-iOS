//
//  EmailSignUpViewController.swift
//  Packing
//
//  Created by 이융의 on 4/2/25.
//

import UIKit

class EmailSignUpViewController: UIViewController {
    
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
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
        
        // textField Delegate
        textField.delegate = self
        textField.tag = 1
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.tag = 3
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
    
    // MARK: - Email Verification Code Section
    
    private lazy var verificationHeaderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
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
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyStyle(MainButtonStyle(color: .main))
        button.configuration?.title = "완료"
        button.isEnabled = false
        button.alpha = 0.8
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - PROPERTIES
    
    private var isValidEmail = false
    private var isValidPassword = false
    private var isValidConfirmPassword = false
    private var isValidName = false
    private var isValidCode = false

    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    private func setupUI() {
//        self.navigationItem.title = "회원가입"
        title = "회원가입"
        view.backgroundColor = .systemBackground
        
        // Setup scrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add content to contentView
        contentView.addSubview(logoImageView)
        contentView.addSubview(mainStackView)
        
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
        
        verificationStackView.addArrangedSubview(verificationLabel)
        verificationStackView.addArrangedSubview(verificationTextField)
        verificationStackView.addArrangedSubview(verificationErrorLabel)
        
        // Add sections to main stack View
        [emailStackView, passwordStackView, confirmPasswordStackView, nameStackView, verificationStackView, nextButton].forEach { stack in
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
            verificationTextField.heightAnchor.constraint(equalToConstant: 48),
            
            // Next Button
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - ACTIONS
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func nextButtonTapped() {
        print(#fileID, #function, #line, "- ")
        print("Email: \(emailTextField.text ?? "")")
        print("Password: \(String(repeating: "*", count: passwordTextField.text!.count))")
        print("Name: \(nameTextField.text ?? "")")
        print("Verification Code: \(verificationTextField.text ?? "")")
        // TODO: 회원가입 로직
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        switch textField.tag {
        case 0: // Email
            if let email = textField.text, !email.isEmpty {
                isValidEmail = validateEmail(email: email)
                emailErrorLabel.isHidden = isValidEmail
                emailErrorLabel.text = isValidEmail ? "" : "유효한 이메일 주소를 입력하세요."
            } else {
                isValidEmail = false
                emailErrorLabel.isHidden = true
            }
            
        case 1: // Password
            if let password = textField.text, !password.isEmpty {
                isValidPassword = validatePassword(password: password)
                passwordErrorLabel.isHidden = isValidPassword
                passwordErrorLabel.text = isValidPassword ? "" : "영문, 숫자를 조합한 8~20자리를 입력하세요."
                
                // Validate confirm password again if it's not empty
                if let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty {
                    isValidConfirmPassword = validatePasswordMatch()
                    confirmPasswordErrorLabel.isHidden = isValidConfirmPassword
                    confirmPasswordErrorLabel.text = isValidConfirmPassword ? "" : "비밀번호가 일치하지 않습니다."
                }
                
            } else {
                    isValidPassword = false
                    passwordErrorLabel.isHidden = true
            }
        case 2: // Confirm Password
            if let confirmPassword = textField.text, !confirmPassword.isEmpty {
                isValidConfirmPassword = validatePasswordMatch()
                confirmPasswordErrorLabel.isHidden = isValidConfirmPassword
                confirmPasswordErrorLabel.text = isValidConfirmPassword ? "" : "비밀번호가 일치하지 않습니다."
            } else {
                isValidConfirmPassword = false
                confirmPasswordErrorLabel.isHidden = true
            }
        case 3: // Name
            if let name = textField.text, !name.isEmpty {
                isValidName = validateName(name: name)
                if name.count > 20 {
                    nameErrorLabel.isHidden = false
                    nameErrorLabel.text = "이름은 20자 이내로 입력해주세요."
                } else {
                    nameErrorLabel.isHidden = true
                }
            } else {
                isValidName = false
                nameErrorLabel.isHidden = true
            }
        case 4: // Code
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
            }
        default: break
        }
        
        updateNextButtonState()
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
    
    // MARK: - VALIDATION
    
    // Email Validation
    private func validateEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    // Password Validation
    private func validatePassword(password: String) -> Bool {
        // Password must contain letters and numbers, and be 8-20 characters long
        // Special characters are allowed but not required
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d\\W_]{8,20}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func validatePasswordMatch() -> Bool {
        return passwordTextField.text == confirmPasswordTextField.text && !passwordTextField.text!.isEmpty
    }
    
    // Name Validation
    private func validateName(name: String) -> Bool {
        return !name.isEmpty && name.count <= 20
    }
    
    // Code Validation
    private func validateCode(code: String) -> Bool {
        // 간단한 검증: 6자리 숫자인지 확인
        let codeRegex = "^[0-9]{6}$"
        let codePredicate = NSPredicate(format: "SELF MATCHES %@", codeRegex)
        return codePredicate.evaluate(with: code)
    }
    
    private func updateNextButtonState() {
        let isFormValid = isValidEmail && isValidPassword && isValidConfirmPassword && isValidName && isValidCode
        nextButton.isEnabled = isFormValid
        nextButton.alpha = isValidCode ? 1.0 : 0.8
    }
}

// MARK: - UI TEXTFIELD DELEGATE
extension EmailSignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0: passwordTextField.becomeFirstResponder()
        case 1: confirmPasswordTextField.becomeFirstResponder()
        case 2: nameTextField.becomeFirstResponder()
        case 3:
            verificationTextField.resignFirstResponder()
            if nextButton.isEnabled {
                nextButtonTapped()
            }
        default: textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - PREVIEW

#Preview {
    EmailSignUpViewController()
}
