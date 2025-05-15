//
//  ProfileViewController.swift
//  Packing
//
//  Created by 이융의 on 4/19/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import Kingfisher

final class ProfileViewController: UIViewController, View {
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
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
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemGray5.cgColor
        imageView.backgroundColor = .main
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수정".localized, for: .normal)
        button.setTitleColor(.main, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = UIColor.systemGray6
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.separatorStyle = .singleLine
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        return table
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private let menuItems = ProfileMenuItem.allCases
    private var tableViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Initializers
    init(reactor: ProfileViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#fileID, #function, #line, "- ")
        reactor?.action.onNext(.refreshProfile)
        
        setupNavigationBarAppearance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableViewHeightConstraint?.isActive = false

        // 테이블뷰 높이를 내용에 맞게 조정
        tableView.layoutIfNeeded()
        let tableViewHeight = tableView.contentSize.height
        
        tableViewHeightConstraint?.constant = tableViewHeight
        tableViewHeightConstraint?.isActive = true

        // 스크롤뷰 컨텐츠 크기 업데이트
        updateScrollViewContentSize()
    }
    
    private func updateScrollViewContentSize() {
        // 스크롤뷰 컨텐츠 크기 재계산 (명시적으로 수행하여 레이아웃 이슈 방지)
        view.layoutIfNeeded()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "내 프로필".localized
        view.backgroundColor = .systemGray6
        
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
        
        // 프로필 이미지 원형 처리
        profileImageView.layer.cornerRadius = 40
        
        // 레이블이 작은 화면에서도 보이도록 압축 저항 우선순위 설정
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bioLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bioLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // 모든 제약 조건을 하나의 NSLayoutConstraint.activate 블록에 통합
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
            profileContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            profileContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            profileContainerView.bottomAnchor.constraint(greaterThanOrEqualTo: editProfileButton.bottomAnchor, constant: 16),
            
            // 프로필 이미지
            profileImageView.topAnchor.constraint(equalTo: profileContainerView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: profileContainerView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // 이름 레이블
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -16),
            
            // 소개 레이블
            bioLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 16),
            bioLabel.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -16),
            
            // 편집 버튼
            editProfileButton.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 16),
            editProfileButton.centerXAnchor.constraint(equalTo: profileContainerView.centerXAnchor),
            editProfileButton.bottomAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: -16),
            editProfileButton.heightAnchor.constraint(equalToConstant: 30),
            
            // 테이블뷰
            tableView.topAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            // 로딩 인디케이터
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // 네비게이션 바에 적용
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupTableView() {
        // RxDataSources를 사용하는 것이 좋지만 간단하게 구현
        Observable.just(menuItems)
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { [weak self] (row, menuItem, cell) in
                guard let self = self else { return }
                
                var content = cell.defaultContentConfiguration()
                content.text = menuItem.displayName
                
                // Configure cell based on menu item
                switch menuItem {
                case .connectedAccount:
                    if let user = self.reactor?.currentState.user {
                        content.secondaryText = self.getSocialTypeName(for: user.socialType ?? .email)
                        let socialIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
                        socialIconView.contentMode = .scaleAspectFit
                        socialIconView.image = self.getSocialTypeImage(for: user.socialType ?? .email)
                        cell.accessoryView = socialIconView
                    }
                    cell.selectionStyle = .none
                case .versionInfo:
                    content.secondaryText = self.getAppVersion()
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
            }
            .disposed(by: disposeBag)
        
        // 테이블뷰 셀 선택 처리
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.handleMenuItemSelection(at: indexPath.row)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Binding
    func bind(reactor: ProfileViewReactor) {
        // Action 바인딩
        editProfileButton.rx.tap
            .observe(on: MainScheduler.instance)
            .map { _ in }
            .subscribe(onNext: { [weak self] _ in
                self?.navigateToEditProfile()
            })
            .disposed(by: disposeBag)
        
        // State 바인딩
        reactor.state.map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.user }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] user in
                self?.updateUserInfo(user)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.error }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.shouldNavigateToLogin }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.navigateToLogin()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Updates
    private func updateUserInfo(_ user: User) {
        // 프로필 이미지 설정
        profileImageView.backgroundColor = .clear
        

        if let imageURL = user.profileImage,
           !imageURL.isEmpty {
            // HTTP를 HTTPS로 변환
            let secureImageURL = imageURL.replacingOccurrences(of: "http://", with: "https://")
            
            if let url = URL(string: secureImageURL) {
                profileImageView.kf.indicatorType = .activity
                profileImageView.kf.setImage(with: url,
                                             placeholder: UIImage(systemName: "person.circle.fill"))
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        nameLabel.text = user.name
        bioLabel.text = user.intro ?? "소개가 없습니다.".localized
        
        tableView.reloadData()
        
        // 스크롤뷰 업데이트
        updateScrollViewContentSize()
    }
    
    // MARK: - Navigation & Helpers
    private func navigateToEditProfile() {
        // 편집 화면으로 이동 로직
        guard let user = reactor?.currentState.user else {
            print(#fileID, #function, #line, "- ")
            return }
        
        let editProfileReactor = EditProfileViewReactor(user: user)
        let editProfileVC = EditProfileViewController(reactor: editProfileReactor)
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    private func navigateToLogin() {
        // 로그인 화면으로 이동
        let loginViewController = LoginViewController()
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UINavigationController(rootViewController: loginViewController)
            window.makeKeyAndVisible()
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
        switch menuItem {
        case .privacy:
            let privacyURL = "https://silicon-distance-ef3.notion.site/1e9f678b2fe280dab47aeea7232736ec?pvs=4"
            let webViewController = WebViewViewController(urlString: privacyURL, title: "개인정보처리방침".localized)
            navigationController?.pushViewController(webViewController, animated: true)
            
        case .legal:
            let termsURL = "https://silicon-distance-ef3.notion.site/1e9f678b2fe28076a4fddb8ef4c4e5e0?pvs=4"
            let webViewController = WebViewViewController(urlString: termsURL, title: "서비스 이용약관".localized)
            navigationController?.pushViewController(webViewController, animated: true)
            
        case .developerInfo:
            let developerURL = "https://github.com/iyungui"
            let webViewController = WebViewViewController(urlString: developerURL, title: "개발자 정보".localized)
            navigationController?.pushViewController(webViewController, animated: true)
            
        default:
            break
        }
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "로그아웃".localized,
            message: "정말 로그아웃 하시겠습니까?".localized,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃".localized, style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.logout)
        })
        
        present(alert, animated: true)
    }
    
    private func showDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "회원탈퇴".localized,
            message: "정말 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.".localized,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "탈퇴하기".localized, style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.deleteAccount)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인".localized, style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
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
            return "네이버".localized
        case .kakao:
            return "카카오".localized
        case .apple:
            return "애플".localized
        case .google:
            return "구글".localized
        case .email:
            return "이메일".localized
        }
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
