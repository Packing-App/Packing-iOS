//
//  FriendRequestsViewController.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class FriendRequestsViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // 테이블뷰 데이터소스 바인딩용 별도 DisposeBag
    private var tableViewDisposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var segmentedControl: UISegmentedControl = {
        let segmented = UISegmentedControl(items: ["받은 요청", "보낸 요청"])
        segmented.selectedSegmentIndex = 0
        segmented.translatesAutoresizingMaskIntoConstraints = false
        return segmented
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ReceivedRequestCell.self, forCellReuseIdentifier: ReceivedRequestCell.identifier)
        tableView.register(SentRequestCell.self, forCellReuseIdentifier: SentRequestCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "친구 요청이 없습니다."
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialize
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let friendshipService = FriendshipService()
        let reactor = FriendRequestsViewReactor(friendshipService: friendshipService)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        // 세그먼트 컨트롤 추가
        view.addSubview(segmentedControl)
        
        // 테이블 뷰 추가
        view.addSubview(tableView)
        
        // 액티비티 인디케이터 추가
        view.addSubview(activityIndicator)
        
        // 빈 상태 레이블 추가
        view.addSubview(emptyStateLabel)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        title = "친구 요청"
    }
    
    // MARK: - ReactorKit Binding
    func bind(reactor: FriendRequestsViewReactor) {
        // Action 바인딩
        
        // 화면 로드 시 친구 요청 목록 로드
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 세그먼트 컨트롤 변경 시 테이블 뷰 업데이트
        segmentedControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] index in
                self?.activityIndicator.stopAnimating()
                self?.setupTableViewDataSource(selectedIndex: index, reactor: reactor)
            })
            .disposed(by: disposeBag)
        
        // State 바인딩
        
        // 로딩 상태 바인딩
        reactor.state.map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 초기 테이블 뷰 데이터 소스 설정
        setupTableViewDataSource(selectedIndex: segmentedControl.selectedSegmentIndex, reactor: reactor)
        
        // 에러 처리
        reactor.state.map { $0.error }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(error)
            })
            .disposed(by: disposeBag)
        
        // 빈 상태 표시 업데이트 - 세그먼트 변경 시
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                if index == 0 {
                    self?.emptyStateLabel.text = "받은 친구 요청이 없습니다."
                    self?.emptyStateLabel.isHidden = !reactor.currentState.receivedRequests.isEmpty
                } else {
                    self?.emptyStateLabel.text = "보낸 친구 요청이 없습니다."
                    self?.emptyStateLabel.isHidden = !reactor.currentState.sentRequests.isEmpty
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func setupTableViewDataSource(selectedIndex: Int, reactor: FriendRequestsViewReactor) {
        // 테이블뷰 데이터소스 연결 해제
        tableView.dataSource = nil
        
        // 이전 데이터소스 바인딩 해제
        tableViewDisposeBag = DisposeBag()
        
        if selectedIndex == 0 {
            // 받은 요청 탭
            reactor.state.map { $0.receivedRequests }
                .observe(on: MainScheduler.instance)
                .distinctUntilChanged()
                .bind(to: tableView.rx.items(cellIdentifier: ReceivedRequestCell.identifier, cellType: ReceivedRequestCell.self)) { index, request, cell in
                    cell.configure(with: request)
                    
                    // 수락 버튼 클릭
                    cell.acceptButton.rx.tap
                        .map { Reactor.Action.respondToRequest(id: request.id, accept: true) }
                        .bind(to: reactor.action)
                        .disposed(by: cell.disposeBag)
                    
                    // 거절 버튼 클릭
                    cell.rejectButton.rx.tap
                        .map { Reactor.Action.respondToRequest(id: request.id, accept: false) }
                        .bind(to: reactor.action)
                        .disposed(by: cell.disposeBag)
                }
                .disposed(by: tableViewDisposeBag)
        } else {
            // 보낸 요청 탭
            reactor.state.map { $0.sentRequests }
                .observe(on: MainScheduler.instance)
                .distinctUntilChanged()
                .bind(to: tableView.rx.items(cellIdentifier: SentRequestCell.identifier, cellType: SentRequestCell.self)) { index, request, cell in
                    cell.configure(with: request)
                }
                .disposed(by: tableViewDisposeBag)
        }
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - ReceivedRequestCell
class ReceivedRequestCell: UITableViewCell {
    static let identifier = "ReceivedRequestCell"
    
    var disposeBag = DisposeBag()
    
    // UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수락", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("거절", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [acceptButton, rejectButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        profileImageView.image = nil
    }
    
    private func setupUI() {
        // Add subviews
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(buttonStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: buttonStackView.leadingAnchor, constant: -12),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            buttonStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStackView.widthAnchor.constraint(equalToConstant: 140),
            acceptButton.heightAnchor.constraint(equalToConstant: 30),
            rejectButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with request: ReceivedFriendRequest) {
        guard let requesterId = request.requesterId else {
            nameLabel.text = "Unknown User"
            emailLabel.text = "Unknown Email"
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .gray
            return
        }
        nameLabel.text = requesterId.name
        emailLabel.text = requesterId.email
        
        if let profileImageUrlString = requesterId.profileImage, let url = URL(string: profileImageUrlString) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .gray
        }
    }
}

// MARK: - SentRequestCell
class SentRequestCell: UITableViewCell {
    static let identifier = "SentRequestCell"
    
    var disposeBag = DisposeBag()
    
    // UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "대기 중"
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        profileImageView.image = nil
    }
    
    private func setupUI() {
        // Add subviews
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(statusLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -12),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
    }
    
    func configure(with request: SentFriendRequest) {
        guard let receiverId = request.receiverId else {
            nameLabel.text = "Unknown User"
            emailLabel.text = "Unknown User"
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .gray
            return
        }
        nameLabel.text = receiverId.name
        emailLabel.text = receiverId.email
        
        if let profileImageUrlString = receiverId.profileImage, let url = URL(string: profileImageUrlString) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .gray
        }
    }
}
