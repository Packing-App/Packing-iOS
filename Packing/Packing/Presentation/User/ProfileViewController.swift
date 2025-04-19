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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#fileID, #function, #line, "- ")
        reactor?.action.onNext(.refreshProfile)
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
        // RxDataSources를 사용하는 것이 좋지만 간단하게 구현
        Observable.just(menuItems)
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { [weak self] (row, menuItem, cell) in
                guard let self = self else { return }
                
                var content = cell.defaultContentConfiguration()
                content.text = menuItem.rawValue
                
                // Configure cell based on menu item
                switch menuItem {
                case .connectedAccount:
                    if let user = self.reactor?.currentState.user {
                        content.secondaryText = self.getSocialTypeName(for: user.socialType)
                        let socialIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
                        socialIconView.contentMode = .scaleAspectFit
                        socialIconView.image = self.getSocialTypeImage(for: user.socialType)
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
        guard let imageURL = user.profileImage else {
//            profileImageView.image = UIImage(systemName: "person.circle.fill")
            return
        }
        if let url = URL(string: imageURL), !imageURL.isEmpty {
//            let pngSerializer = FormatIndicatedCacheSerializer.png
            profileImageView.kf.indicatorType = .activity
            profileImageView.kf.setImage(with: url)
        } else {
//            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
        /*
         cell.sampleImageView.kf.indicatorType = .activity
         
         let roundCorner = RoundCornerImageProcessor(radius: .widthFraction(0.5), roundingCorners: [.topLeft, .bottomRight])
         let pngSerializer = FormatIndicatedCacheSerializer.png
         cell.sampleImageView.kf.setImage(
             with: url,
             options: [.processor(roundCorner), .cacheSerializer(pngSerializer)]
         )
         cell.sampleImageView.backgroundColor = .clear
         */
        
        // 이름과 소개 설정
        nameLabel.text = user.name
        bioLabel.text = user.intro ?? "소개가 없습니다."
        
        // 테이블뷰 리로드 (소셜 로그인 타입이 변경될 수 있으므로)
        tableView.reloadData()
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
