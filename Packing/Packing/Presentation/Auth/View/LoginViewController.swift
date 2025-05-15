//
//  LoginViewController.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import AuthenticationServices

// MARK: - UI VIEW

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel: LoginViewModel
    private let deviceService: DeviceServiceProtocol = DeviceService()

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
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
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
        
        // 폰트 크기를 약간 키우고, 이미지 크기도 조정
        let font = UIFont.systemFont(ofSize: 13, weight: .semibold) // 10 -> 13으로 크기 증가
        let fontCapHeight = font.capHeight
        let yOffset = (fontCapHeight - 18.0) / 2  // 이미지 높이(18)와 폰트 높이 차이의 절반만큼 조정
        
        imageAttachment.bounds = CGRect(x: 0, y: yOffset, width: 18, height: 18) // 15 -> 18로 크기 증가
        
        // 현재 텍스트와 이미지 결합
        let attributedString = NSMutableAttributedString(string: "3초만에 시작하기  ")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        label.attributedText = attributedString
        label.sizeToFit()
        
        // 레이블 설정
        label.textAlignment = .center
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 14 // 약간 더 증가된 둥근 모서리
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // border
        containerView.layer.borderWidth = 0.8
        containerView.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8), // 5 -> 8로 여백 증가
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8), // 5 -> 8로 여백 증가
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16), // 12 -> 16으로 여백 증가
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16) // 12 -> 16으로 여백 증가
        ])
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOpacity = 0.2
        
        return containerView
    }()
    
    private lazy var socialLoginButtons: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16 // 8 -> 16으로 간격 증가
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var emailLoginButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .medium
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = UIColor(named: "mainColor")
        configuration.buttonSize = .large
        configuration.title = "이메일로 로그인"
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        
        // 폰트 스타일 설정
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        
        let button = UIButton(configuration: configuration)
        
        // 그림자 효과 추가
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.2
        button.clipsToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    private lazy var guestModeButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "로그인 없이 시작하기"
        configuration.baseForegroundColor = UIColor(named: "mainColor")
        
        // 폰트 스타일 설정
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            return outgoing
        }
        
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        title = "패킹"
        view.backgroundColor = .systemBackground
        
        view.addSubview(logoImageView)
        view.addSubview(subtitleLabel)
        view.addSubview(loginPromptLabel)
        view.addSubview(socialLoginButtons)
        view.addSubview(loadingIndicator)
        view.addSubview(emailLoginButton)
        view.addSubview(guestModeButton)
        
        socialLoginButtons.addArrangedSubview(googleLoginButton)
        socialLoginButtons.addArrangedSubview(kakaoLoginButton)
        socialLoginButtons.addArrangedSubview(naverLoginButton)
        socialLoginButtons.addArrangedSubview(appleLoginButton)
        
        // NSLayoutConstraint를 사용한 레이아웃 설정
        NSLayoutConstraint.activate([
            // 로고 이미지 뷰
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48), // 더 여유있는 상단 여백
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 180), // 약간 더 크게
            logoImageView.heightAnchor.constraint(equalToConstant: 180), // 정사각형 비율 유지
            
            // 부제목 레이블
            subtitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24), // 30 -> 24
            subtitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 로그인 프롬프트 레이블
            loginPromptLabel.bottomAnchor.constraint(equalTo: socialLoginButtons.topAnchor, constant: -24), // 더 여유있는 간격
            loginPromptLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 소셜 로그인 버튼 그룹
            socialLoginButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            socialLoginButtons.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 60), // 70 -> 60
            socialLoginButtons.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60), // 70 -> 60
            socialLoginButtons.bottomAnchor.constraint(equalTo: emailLoginButton.topAnchor, constant: -32), // 30 -> 32
            
            // 각 소셜 로그인 버튼 크기 설정
            googleLoginButton.widthAnchor.constraint(equalToConstant: 50),
            googleLoginButton.heightAnchor.constraint(equalToConstant: 50),
            kakaoLoginButton.widthAnchor.constraint(equalToConstant: 50),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 50),
            naverLoginButton.widthAnchor.constraint(equalToConstant: 50),
            naverLoginButton.heightAnchor.constraint(equalToConstant: 50),
            appleLoginButton.widthAnchor.constraint(equalToConstant: 50),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 이메일 로그인 버튼
            emailLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLoginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40), // 70 -> 40
            emailLoginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40), // 70 -> 40
            emailLoginButton.heightAnchor.constraint(equalToConstant: 50), // 50 -> 55로 높이 증가
            emailLoginButton.bottomAnchor.constraint(equalTo: guestModeButton.topAnchor, constant: -20), // 16 -> 20
            
            // 게스트 모드 버튼
            guestModeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guestModeButton.heightAnchor.constraint(equalToConstant: 44), // 적절한 터치 영역
            guestModeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28), // 20 -> 28로 여백 증가

            // 로딩 인디케이터
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func createSocialLoginButton(_ type: String) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: type), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 접근성 레이블 설정
        switch type {
        case "google":
            button.accessibilityLabel = "구글로 로그인"
        case "kakao":
            button.accessibilityLabel = "카카오로 로그인"
        case "naver":
            button.accessibilityLabel = "네이버로 로그인"
        case "apple":
            button.accessibilityLabel = "애플로 로그인"
        default:
            break
        }
        
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
        
        guestModeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.startGuestMode()
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
    
    private func navigateToEmailLogin() {
        let emailLoginVC = EmailLoginViewController()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(emailLoginVC, animated: true)
    }
    
    private func navigateToMainScreen() {
        AuthCoordinator.shared.showMainScreen()
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
