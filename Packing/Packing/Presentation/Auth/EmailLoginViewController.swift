//
//  EmailLoginViewController.swift
//  Packing
//
//  Created by 이융의 on 3/31/25.
//

import UIKit
class EmailLoginViewController: UIViewController {
    
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
        
//        let button = UIButton(type: .system)
//        button.setTitle("로그인", for: .normal)
//        button.backgroundColor = .main
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 8
//        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyStyle(MainButtonStyle(color: .black))
        button.configuration?.title = "회원가입"
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
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
            
            signUpButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 24),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)
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
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // 여기에 입력 검증 로직 추가
            return
        }
        
        // 로그인 로직 구현
        print("로그인 시도: \(email)")
    }
    @objc private func signUpButtonTapped() {
        print(#fileID, #function, #line, "- ")
        
        let signUpViewController = EmailSignUpViewController()
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
}


#Preview {
    EmailLoginViewController()
}
