//
//  LoginViewController.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import AuthenticationServices

// MARK: - UI VIEW

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel: LoginViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI COMPONENTS

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
    
    private lazy var socialLoginButtons: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var emailLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.applyStyle(MainButtonStyle(color: .main))
        button.configuration?.title = "이메일로 로그인"
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
    
    // MARK: - Initialize
    
    init(viewModel: LoginViewModel = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "PACKING"
        view.backgroundColor = .systemBackground
        
        view.addSubview(logoImageView)
        view.addSubview(subtitleLabel)
        view.addSubview(loginPromptLabel)
        view.addSubview(socialLoginButtons)
        view.addSubview(loadingIndicator)
        view.addSubview(emailLoginButton)
        
        socialLoginButtons.addArrangedSubview(googleLoginButton)
        socialLoginButtons.addArrangedSubview(kakaoLoginButton)
        socialLoginButtons.addArrangedSubview(naverLoginButton)
        socialLoginButtons.addArrangedSubview(appleLoginButton)
        
        // TODO: constraints with snapkit
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            
            subtitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loginPromptLabel.bottomAnchor.constraint(equalTo: socialLoginButtons.topAnchor, constant: -20),
            loginPromptLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            socialLoginButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            socialLoginButtons.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 70),
            socialLoginButtons.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70),
            socialLoginButtons.bottomAnchor.constraint(equalTo: emailLoginButton.topAnchor, constant: -30),
            
            emailLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLoginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 70),
            emailLoginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70),
            emailLoginButton.heightAnchor.constraint(equalToConstant: 50),
            emailLoginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
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
    
    private func bindViewModel() {
        emailLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigateToEmailLogin()
            })
            .disposed(by: disposeBag)
        
        googleLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.performSocialLogin(from: self, type: .google)
            })
            .disposed(by: disposeBag)
        
        // 카카오 로그인 버튼 액션
        kakaoLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.performSocialLogin(from: self, type: .kakao)
            })
            .disposed(by: disposeBag)
        
        // 네이버 로그인 버튼 액션
        naverLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.performSocialLogin(from: self, type: .naver)
            })
            .disposed(by: disposeBag)
        
        // 애플 로그인 버튼 액션
        appleLoginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.performAppleLogin(from: self)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태 바인딩
        viewModel.isLoading
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 로그인 결과 바인딩
        viewModel.loginResult
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    // 로그인 성공 - 메인 화면으로 이동
                    self?.navigateToMainScreen()
                case .failure(let error):
                    // 로그인 실패 - 에러 메시지 표시
                    self?.showAlert(message: error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
        
        // 에러 메시지 바인딩
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] message in
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigation & Helpers
    
    private func navigateToEmailLogin() {
        let emailLoginVC = EmailLoginViewController()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(emailLoginVC, animated: true)
    }
    
    private func navigateToMainScreen() {
        // 진짜 LoginViewController를 생성
        let myPageViewController = MyPageViewController()
        
        // 루트 뷰 컨트롤러로 설정하여 뒤로가기를 방지
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UINavigationController(rootViewController: myPageViewController)
            window.makeKeyAndVisible()
            
            // animation (optional)
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}




#Preview {
    UINavigationController(rootViewController: LoginViewController())
}
