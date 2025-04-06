//
//  MyPageViewController.swift
//  Packing
//
//  Created by 이융의 on 4/2/25.
//

import UIKit

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


class MyPageViewController: UIViewController {
    
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
        button.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        
        table.separatorStyle = .singleLine
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false // 테이블뷰 자체 스크롤 비활성화
        return table
    }()
    
    // MARK: - PROPERTIES
    
    var user = User.exampleUser
    private let menuItems = ProfileMenuItem.allCases
    private var tableViewHeightConstraint: NSLayoutConstraint?

    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    private func setupUI() {
        title = "내 프로필"
        view.backgroundColor = .systemGray6
        
        if let imageName = user.profileImage, !imageName.isEmpty, let image = UIImage(named: imageName) {
            profileImageView.image = image
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .white
        }
        
        nameLabel.text = user.name
        bioLabel.text = user.intro
        
        profileContainerView.addSubview(profileImageView)
        profileContainerView.addSubview(nameLabel)
        profileContainerView.addSubview(bioLabel)
        profileContainerView.addSubview(editProfileButton)
        
        
        // 스크롤뷰 설정
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 콘텐츠뷰에 컨텐츠 추가
        contentView.addSubview(profileContainerView)
        contentView.addSubview(tableView)
        
        
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
            contentView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20)
        ])
        
        // 초기 테이블뷰 높이 설정 (이후 viewDidLayoutSubviews에서 동적으로 조정됨)
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: CGFloat(menuItems.count * 44))
        tableViewHeightConstraint?.isActive = true
    }
    
    // MARK: - ACTIONS
    
    @objc private func editProfileButtonTapped() {
        print(#fileID, #function, #line, "- Edit profile button tapped")
    }
    
    private func getSocialTypeImage() -> UIImage? {
        switch user.socialType {
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
    
    private func getSocialTypeName() -> String {
        switch user.socialType {
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
    
    private func navigateToViewController(for menuItem: ProfileMenuItem) {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        viewController.title = menuItem.rawValue
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            print("User logged out")
            // Handle logout logic here
        })
        
        present(alert, animated: true)
    }
    
    private func showDeleteAccountAlert() {
        let alert = UIAlertController(
            title: "회원탈퇴",
            message: "정말 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in
            print("User account deleted")
            // Handle account deletion logic here
        })
        
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
            content.secondaryText = getSocialTypeName()
            let socialIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            socialIconView.contentMode = .scaleAspectFit
            socialIconView.image = getSocialTypeImage()
            cell.accessoryView = socialIconView
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = menuItems[indexPath.row]
        switch menuItem {
        case .connectedAccount, .versionInfo: break
        case .developerInfo, .privacy, .legal: navigateToViewController(for: menuItem)
        case .logout: showLogoutAlert()
        case .deleteId: showDeleteAccountAlert()
        }
    }
}


// MARK: - PREVIEW

#Preview {
    let viewController = MyPageViewController()
    let navigationViewController = UINavigationController(rootViewController: viewController)
    return navigationViewController
}
