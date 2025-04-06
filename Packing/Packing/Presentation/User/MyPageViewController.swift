//
//  MyPageViewController.swift
//  Packing
//
//  Created by 이융의 on 4/2/25.
//

import UIKit

/*
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

*/

// Presentation/MyPage/MyPageViewController.swift

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit

class MyPageViewController: UIViewController, StoryboardView {
    
    typealias Reactor = MyPageReactor
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let changeProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("사진 변경", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름을 입력하세요"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.text = "자기소개"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let introTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5
        textView.font = .systemFont(ofSize: 14)
        return textView
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let emailValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("계정 삭제", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "내 프로필"
        
        // 스크롤 뷰 설정
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 컨텐츠 추가
        contentView.addSubview(profileImageView)
        contentView.addSubview(changeProfileButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(introLabel)
        contentView.addSubview(introTextView)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailValueLabel)
        contentView.addSubview(saveButton)
        contentView.addSubview(logoutButton)
        contentView.addSubview(deleteAccountButton)
        contentView.addSubview(activityIndicator)
        
        // 제약 조건 설정
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
            make.height.greaterThanOrEqualTo(view.snp.height).priority(.low)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        changeProfileButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(changeProfileButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        introLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        introTextView.snp.makeConstraints { make in
            make.top.equalTo(introLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(introTextView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        emailValueLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(emailValueLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        deleteAccountButton.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupKeyboardHandling() {
        // 키보드가 올라올 때 스크롤 조정
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let self = self,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return
                }
                
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
            })
            .disposed(by: disposeBag)
        
        // 키보드가 내려갈 때 스크롤 원복
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let contentInsets = UIEdgeInsets.zero
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
            })
            .disposed(by: disposeBag)
        
        // 배경 탭 시 키보드 내리기
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Binding
    
    func bind(reactor: MyPageReactor) {
        // Initial load
        Observable.just(Reactor.Action.loadProfile)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Action
        nameTextField.rx.text.orEmpty
            .map { Reactor.Action.updateName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        introTextView.rx.text.orEmpty
            .map { Reactor.Action.updateIntro($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { Reactor.Action.saveProfile }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        changeProfileButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.presentImagePicker()
            })
            .disposed(by: disposeBag)
        
        logoutButton.rx.tap
            .map { Reactor.Action.logout }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteAccountButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.showDeleteAccountAlert()
            })
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.saveButton.isEnabled = false
                    self?.saveButton.alpha = 0.5
                } else {
                    self?.activityIndicator.stopAnimating()
                    let isSaveEnabled = reactor.currentState.isSaveEnabled
                    self?.saveButton.isEnabled = isSaveEnabled
                    self?.saveButton.alpha = isSaveEnabled ? 1.0 : 0.5
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.user }
            .distinctUntilChanged { $0?.id == $1?.id }
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] user in
                guard let user = user else { return }
                
                self?.nameTextField.text = user.name
                self?.introTextView.text = user.intro
                self?.emailValueLabel.text = user.email
                
                // 프로필 이미지 로드
                if let profileImageUrl = user.profileImage, let url = URL(string: profileImageUrl) {
                    self?.loadProfileImage(from: url)
                } else {
                    self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isSaveEnabled }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isEnabled in
                self?.saveButton.isEnabled = isEnabled
                self?.saveButton.alpha = isEnabled ? 1.0 : 0.5
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
        
        reactor.state.map { $0.isLoggedOut }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                // 로그아웃 성공 후 로그인 화면으로 이동
                self?.navigateToLoginScreen()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isAccountDeleted }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                // 계정 삭제 성공 후 로그인 화면으로 이동
                self?.navigateToLoginScreen()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Methods
    
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("프로필 이미지 로드 오류: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
    
    private func showDeleteAccountAlert() {
        let alert = UIAlertController(
            title: "계정 삭제",
            message: "정말로 계정을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.reactor?.action.onNext(.deleteAccount)
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToLoginScreen() {
        let authService = AuthService()
        let loginReactor = LoginReactor(authService: authService, presentingViewController: UIViewController())
        let loginVC = LoginViewController()
        loginVC.reactor = loginReactor
        
        let navigationController = UINavigationController(rootViewController: loginVC)
        UIApplication.shared.windows.first?.rootViewController = navigationController
    }
}

// MARK: - UIImagePickerControllerDelegate

extension MyPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            return
        }
        
        // 이미지 업데이트
        profileImageView.image = selectedImage
        
        // 리액터에 이미지 업데이트 액션 전달
        reactor?.action.onNext(.updateProfileImage(selectedImage))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
