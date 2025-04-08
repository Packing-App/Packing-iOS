//
//  MyPageViewController.swift
//  Packing
//
//  Created by 이융의 on 4/2/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

enum ProfileMenuItem: String, CaseIterable {
    case connectedAccount = "연결된 계정" // (just display)
    case versionInfo = "버전 정보"  // (just display)
    case developerInfo = "개발자 정보"   // navigate to another View
    case privacy = "개인정보처리방침"  // navigate to another View
    case legal = "서비스 이용약관"  // navigate to another View
    case logout = "로그아웃"    // button (show alert)
    case deleteId = "회원탈퇴"  // button (show alert)
    
    var isDestructive: Bool {
        return self == .logout || self == .deleteId
    }
    
    var isNavigatable: Bool {
        return self == .developerInfo || self == .privacy || self == .legal
    }
    
    var isDisplayOnly: Bool {
        return self == .connectedAccount || self == .versionInfo
    }
}


class MyPageViewController: UIViewController, View {
    
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
    
    private lazy var profileContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수정", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        //        button.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.separatorStyle = .singleLine
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false // 테이블뷰 자체 스크롤 비활성화
        return table
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - PROPERTIES
    
    typealias Reactor = MyPageViewReactor
    var disposeBag = DisposeBag()
    
    private let menuItems = ProfileMenuItem.allCases
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Initialize
    
    init(reactor: MyPageViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 화면이 나타날 때마다 최신 사용자 정보 로드
        reactor?.action.onNext(.refresh)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 테이블뷰 높이를 동적으로 조정
        let height = tableView.contentSize.height
        if let heightConstraint = tableViewHeightConstraint {
            heightConstraint.constant = height
        } else {
            tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: height)
            tableViewHeightConstraint?.isActive = true
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "내 프로필"
        view.backgroundColor = .systemGray6
        
        //        if let imageName = user.profileImage, !imageName.isEmpty, let image = UIImage(named: imageName) {
        //            profileImageView.image = image
        //        } else {
        //            profileImageView.image = UIImage(systemName: "person.circle.fill")
        //            profileImageView.tintColor = .white
        //        }
        
        //        nameLabel.text = user.name
        //        bioLabel.text = user.intro
        
        
        
        // 스크롤뷰 설정
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 콘텐츠뷰에 컨텐츠 추가
        contentView.addSubview(profileContainerView)
        contentView.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        profileContainerView.addSubview(profileImageView)
        profileContainerView.addSubview(nameLabel)
        profileContainerView.addSubview(bioLabel)
        profileContainerView.addSubview(editProfileButton)
        
        NSLayoutConstraint.activate([
            // 스크롤뷰
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // 콘텐츠뷰
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 프로필 컨테이너 뷰
            profileContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // 프로필 이미지
            profileImageView.topAnchor.constraint(equalTo: profileContainerView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: profileContainerView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // 이름 레이블
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: profileContainerView.centerXAnchor),
            nameLabel.leadingAnchor.constraint(lessThanOrEqualTo: profileContainerView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: profileContainerView.trailingAnchor, constant: -20),
            
            // 소개 레이블
            bioLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            bioLabel.centerXAnchor.constraint(equalTo: profileContainerView.centerXAnchor),
            bioLabel.leadingAnchor.constraint(lessThanOrEqualTo: profileContainerView.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(lessThanOrEqualTo: profileContainerView.trailingAnchor, constant: -20),
            
            // 편집 버튼
            editProfileButton.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 20),
            editProfileButton.centerXAnchor.constraint(equalTo: profileContainerView.centerXAnchor),
            editProfileButton.bottomAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: -20),
            
            // 테이블뷰
            tableView.topAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // 콘텐츠뷰의 하단을 테이블뷰의 하단에 연결 (중요!)
            contentView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            
            // 로딩 인디케이터
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 초기 테이블뷰 높이 설정 (이후 viewDidLayoutSubviews에서 동적으로 조정됨)
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: CGFloat(menuItems.count * 44))
        tableViewHeightConstraint?.isActive = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self // Keep this for data

        // Use rx.setDelegate instead of direct assignment
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    // MARK: - ReactorKit Binding
    
    func bind(reactor: MyPageViewReactor) {
        bindActions(reactor)
        bindState(reactor)
        bindTableView()
    }
    
    
    private func bindActions(_ reactor: MyPageViewReactor) {
        // 프로필 편집 버튼 액션
        editProfileButton.rx.tap
            .map { Reactor.Action.editProfile }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 프로필 편집 화면으로 이동 (별도 처리)
        editProfileButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigateToEditProfile()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(_ reactor: MyPageViewReactor) {
        // 사용자 정보 바인딩
        reactor.state
            .map { $0.user }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] user in
                self?.updateUserInfo(user)
            })
            .disposed(by: disposeBag)
        
        // 로딩 상태 바인딩
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 에러 메시지 바인딩
        reactor.state
            .compactMap { $0.errorMessage }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] message in
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.user }
            .distinctUntilChanged { $0?.id == $1?.id } // ID로 비교
            .filter { $0 == nil }
            .do(onNext: { _ in print("사용자가 null이 되었습니다. 로그인 화면으로 이동합니다.") })
            .observe(on: MainScheduler.instance) // 메인 스레드에서 UI 업데이트
            .subscribe(onNext: { [weak self] _ in
                self?.navigateToLogin()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .debounce(.seconds(10), scheduler: MainScheduler.instance)
            .filter { $0 == true } // 10초 후에도 로딩 중이면 진행
            .subscribe(onNext: { [weak self] _ in
                print("로딩이 10초 이상 지속됩니다. 강제로 로딩 상태를 해제합니다.")
                self?.showAlert(message: "서버 응답이 느립니다. 다시 시도해 주세요.")
                self?.loadingIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindTableView() {
        // 테이블뷰 셀 선택 이벤트
        print(#fileID, #function, #line, "- ")
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.handleMenuItemSelection(at: indexPath.row)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Updates
    private func updateUserInfo(_ user: User?) {
        print(#fileID, #function, #line, "- ")
        guard let user = user else { return }
        
        // 프로필 이미지 설정
        if let imageURL = user.profileImage, !imageURL.isEmpty {
            // 여기서는 간단하게 처리했지만, 실제로는 이미지 로딩 라이브러리(Kingfisher 등) 사용 권장
            if let image = UIImage(named: imageURL) {
                profileImageView.image = image
            } else {
                // URL에서 이미지 로드 로직 (생략)
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        // 이름과 소개 설정
        nameLabel.text = user.name
        bioLabel.text = user.intro ?? "소개가 없습니다."
        
        // 테이블뷰 리로드 (소셜 로그인 타입이 변경될 수 있으므로)
        tableView.reloadData()
    }
    
    // MARK: - Navigation & Helpers
    
    private func navigateToEditProfile() {
        print("프로필 편집 화면으로 이동")
        
        // 실제 구현 시 아래와 같이 처리
        // let editProfileVC = EditProfileViewController(reactor: EditProfileViewReactor(user: reactor?.currentState.user))
        // navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    private func navigateToLogin() {
        // 로그아웃 or 계정 삭제 후 로그인 화면으로 이동
        
        let loginViewReactor = LoginViewReactor()
        let loginViewController = LoginViewController(reactor: loginViewReactor)
        
        // 루트 뷰 컨트롤러로 설정하여 뒤로가기를 방지
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UINavigationController(rootViewController: loginViewController)
            window.makeKeyAndVisible()
            
            // animation (optional)
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    private func handleMenuItemSelection(at index: Int) {
        let menuItem = menuItems[index]
        
        switch menuItem {
        case .connectedAccount, .versionInfo:
            // 표시 전용 항목은 아무 동작 없음
            break
            
        case .developerInfo, .privacy, .legal:
            navigateToInfoScreen(for: menuItem)
            
        case .logout:
            showLogoutConfirmation()
            
        case .deleteId:
            showDeleteAccountConfirmation()
        }
    }
    
    private func navigateToInfoScreen(for menuItem: ProfileMenuItem) {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        viewController.title = menuItem.rawValue
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.logout)
        })
        
        present(alert, animated: true)
    }
    
    private func showDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "회원탈퇴",
            message: "정말 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "탈퇴하기", style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.deleteAccount)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let menuItem = menuItems[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = menuItem.rawValue
        
        // Configure cell based on menu item
        switch menuItem {
        case .connectedAccount:
            if let user = reactor?.currentState.user {
                content.secondaryText = getSocialTypeName(for: user.socialType)
                let socialIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
                socialIconView.contentMode = .scaleAspectFit
                socialIconView.image = getSocialTypeImage(for: user.socialType)
                cell.accessoryView = socialIconView
            }
            cell.selectionStyle = .none
        case .versionInfo:
            content.secondaryText = getAppVersion()
            cell.accessoryView = nil
            cell.accessoryType = .none
            cell.selectionStyle = .none
            
        case .developerInfo, .privacy, .legal:
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
            
        case .logout, .deleteId:
            content.textProperties.color = .systemRed
            cell.accessoryView = nil
            cell.accessoryType = .none
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    private func getSocialTypeImage(for type: LoginType) -> UIImage? {
        switch type {
        case .naver:
            return UIImage(named: "naver")
        case .kakao:
            return UIImage(named: "kakao")
        case .apple:
            return UIImage(named: "apple")
        case .google:
            return UIImage(named: "google")
        case .email:
            return UIImage(systemName: "envelope.fill")
        }
    }
    
    private func getSocialTypeName(for type: LoginType) -> String {
        switch type {
        case .naver:
            return "네이버"
        case .kakao:
            return "카카오"
        case .apple:
            return "애플"
        case .google:
            return "구글"
        case .email:
            return "이메일"
        }
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}


// MARK: - PREVIEW

#Preview {
    let viewReactor = MyPageViewReactor()
    let viewController = MyPageViewController(reactor: viewReactor)
    let navigationViewController = UINavigationController(rootViewController: viewController)
    return navigationViewController
}
