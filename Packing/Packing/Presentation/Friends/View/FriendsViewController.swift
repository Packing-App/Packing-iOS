//
//  FriendsViewController.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class FriendsViewController: UIViewController, View {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "이메일로 친구 검색"
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.returnKeyType = .search
        return controller
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.identifier)
        tableView.register(FriendSearchResultCell.self, forCellReuseIdentifier: FriendSearchResultCell.identifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.backgroundColor = .systemGroupedBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addFriendButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "person.badge.plus")
        button.setImage(image, for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.2.slash")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyStateTitle: UILabel = {
        let label = UILabel()
        label.text = "친구 목록이 비어있습니다"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateSubtitle: UILabel = {
        let label = UILabel()
        label.text = "친구를 추가하여 함께 여행 계획을 세워보세요"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("친구 추가하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - INITIALIZE
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let friendshipService = FriendshipService()
        let reactor = FriendsViewReactor(friendshipService: friendshipService)
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
        setupEmptyState()
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh friends list when returning to this screen
        if let reactor = self.reactor {
            reactor.action.onNext(.viewDidLoad)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // 테이블 뷰 추가
        view.addSubview(tableView)
        
        // 액티비티 인디케이터 추가
        view.addSubview(activityIndicator)
        
        // 친구 추가 플로팅 버튼 추가
        view.addSubview(addFriendButton)
        
        // 빈 상태 뷰 추가
        view.addSubview(emptyStateView)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            addFriendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addFriendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addFriendButton.widthAnchor.constraint(equalToConstant: 56),
            addFriendButton.heightAnchor.constraint(equalToConstant: 56),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 240),
        ])
        
        // Add tap gesture for FAB
        addFriendButton.addTarget(self, action: #selector(addFriendButtonTapped), for: .touchUpInside)
    }
    
    private func setupEmptyState() {
        // 빈 상태 뷰 구성
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateTitle)
        emptyStateView.addSubview(emptyStateSubtitle)
        emptyStateView.addSubview(emptyStateButton)
        
        NSLayoutConstraint.activate([
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),
            
            emptyStateTitle.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateTitle.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateTitle.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateSubtitle.topAnchor.constraint(equalTo: emptyStateTitle.bottomAnchor, constant: 8),
            emptyStateSubtitle.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubtitle.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyStateButton.topAnchor.constraint(equalTo: emptyStateSubtitle.bottomAnchor, constant: 20),
            emptyStateButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateButton.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
        
        // 버튼 액션 설정
        emptyStateButton.addTarget(self, action: #selector(addFriendButtonTapped), for: .touchUpInside)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "내 친구"
        // 검색 컨트롤러 설정
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        // 알림 버튼 추가
        let friendRequestsButton = UIBarButtonItem(
            image: UIImage(systemName: "person.crop.circle.badge.questionmark"),
            style: .plain,
            target: self,
            action: #selector(friendRequestsButtonTapped)
        )
        navigationItem.rightBarButtonItem = friendRequestsButton
    }
    
    @objc private func friendRequestsButtonTapped() {
        // 친구 요청 화면으로 이동
        let requestsViewController = FriendRequestsViewController()
        let requestsReactor = FriendRequestsViewReactor()
        requestsViewController.reactor = requestsReactor
        
        navigationController?.pushViewController(requestsViewController, animated: true)
    }
    
    @objc private func addFriendButtonTapped() {
        // 검색 컨트롤러 활성화
        searchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: - ReactorKit Binding
    func bind(reactor: FriendsViewReactor) {
        // Action 바인딩
        
        // 화면 로드 시 친구 목록 로드
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 검색바 입력 관찰
        searchController.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)  // 이 부분 추가
            .map { Reactor.Action.searchFriend($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 검색 취소 버튼 클릭 관찰
        searchController.searchBar.rx.cancelButtonClicked
            .map { Reactor.Action.clearSearch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State 바인딩
        
        // 로딩 상태 바인딩
        reactor.state.map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 뷰 모드에 따른 데이터 소스 설정
        reactor.state.map { $0.viewMode }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] mode in
                self?.setupDataSource(mode: mode, reactor: reactor)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        reactor.state.map { $0.error }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(error)
            })
            .disposed(by: disposeBag)
        
        // 빈 상태 표시 처리
        reactor.state.map { state -> Bool in
            switch state.viewMode {
            case .friendsList:
                return state.friends.isEmpty && !state.isLoading
            case .searchResults:
                return state.searchResults.isEmpty && !state.isLoading
            }
        }
        .observe(on: MainScheduler.instance)
        .distinctUntilChanged()
        .bind(to: emptyStateView.rx.isHidden.mapObserver { !$0 })
        .disposed(by: disposeBag)
        
        // 빈 상태 텍스트 변경
        reactor.state.map { $0.viewMode }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] mode in
                print("mode: \(mode)")
                switch mode {
                case .friendsList:
                    self?.emptyStateTitle.text = "친구 목록이 비어있습니다"
                    self?.emptyStateSubtitle.text = "친구를 추가하여 함께 여행 계획을 세워보세요"
                    self?.emptyStateButton.setTitle("친구 추가하기", for: .normal)
                    self?.emptyStateImageView.image = UIImage(systemName: "person.2.slash")
                case .searchResults:
                    self?.emptyStateTitle.text = "검색 결과가 없습니다"
                    self?.emptyStateSubtitle.text = "다른 이메일로 검색해보세요"
                    self?.emptyStateButton.setTitle("친구 추가하기", for: .normal)
                    self?.emptyStateImageView.image = UIImage(systemName: "magnifyingglass")
                }
            })
            .disposed(by: disposeBag)
        
        // 플로팅 버튼 표시 여부
        reactor.state.map { $0.viewMode }
            .observe(on: MainScheduler.instance)
            .map { $0 == .friendsList }
            .bind(to: addFriendButton.rx.isHidden.mapObserver { !$0 })
            .disposed(by: disposeBag)
    }

    private var tableViewDisposeBag = DisposeBag()

    // MARK: - Private Methods
    private func setupDataSource(mode: FriendsViewReactor.ViewMode, reactor: FriendsViewReactor) {
        tableView.dataSource = nil
        
        // 테이블뷰 바인딩을 위한 DisposeBag 초기화
        tableViewDisposeBag = DisposeBag()

        switch mode {
        case .friendsList:
            // 친구 목록 모드
            reactor.state.map { $0.friends }
                .observe(on: MainScheduler.asyncInstance)
                .distinctUntilChanged()
                .bind(to: tableView.rx.items(cellIdentifier: FriendCell.identifier, cellType: FriendCell.self)) { [weak self] index, friend, cell in
                    cell.configure(with: friend)
                    
                    // 초대 버튼 설정
                    cell.inviteButton.rx.tap
                        .observe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: { [weak self] _ in
                            self?.showJourneySelectionForFriend(friend)
                        })
                        .disposed(by: cell.disposeBag)
                }
                .disposed(by: tableViewDisposeBag)
                
        case .searchResults:
            // 검색 결과 모드
            reactor.state.map { $0.searchResults }
                .observe(on: MainScheduler.asyncInstance)
                .distinctUntilChanged()
                .bind(to: tableView.rx.items(cellIdentifier: FriendSearchResultCell.identifier, cellType: FriendSearchResultCell.self)) { index, result, cell in
                    cell.configure(with: result)

                    // 친구 상태에 따라 버튼 설정
                    if let friendshipStatus = result.friendshipStatus, friendshipStatus == .accepted {
                        // 이미 친구인 경우 - 이 검색결과는 표시하지 않음 (이미 친구 목록에 있으므로)
                        cell.actionButton.setTitle("이미 친구", for: .normal)
                        cell.actionButton.backgroundColor = .systemGray5
                        cell.actionButton.setTitleColor(.systemGray, for: .normal)
                        cell.actionButton.isEnabled = false
                    } else if let friendshipStatus = result.friendshipStatus, friendshipStatus == .pending {
                        // 요청 중인 경우 - 비활성화된 버튼 표시
                        cell.actionButton.setTitle("요청 중", for: .normal)
                        cell.actionButton.backgroundColor = .systemGray5
                        cell.actionButton.setTitleColor(.systemGray, for: .normal)
                        cell.actionButton.isEnabled = false
                    } else {
                        // 친구 아닌 경우 - 요청 버튼 표시
                        cell.actionButton.setTitle("친구 요청", for: .normal)
                        cell.actionButton.backgroundColor = .systemBlue
                        cell.actionButton.setTitleColor(.white, for: .normal)
                        cell.actionButton.isEnabled = true
                        
                        cell.actionButton.rx.tap
                            .observe(on: MainScheduler.asyncInstance)
                            .map { Reactor.Action.sendFriendRequest(result.email) }
                            .bind(to: reactor.action)
                            .disposed(by: cell.disposeBag)
                    }
                }
                .disposed(by: tableViewDisposeBag)
        }
    }
    
    private func showJourneySelectionForFriend(_ friend: Friend) {
        let journeySelectionVC = JourneySelectionViewController()
        journeySelectionVC.selectedFriend = friend
        journeySelectionVC.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(journeySelectionVC, animated: true)
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

extension FriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let reactor = self.reactor, reactor.currentState.viewMode == .friendsList else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            
            let friend = reactor.currentState.friends[indexPath.row]
            
            // 확인 알림 표시
            let alert = UIAlertController(
                title: "친구 삭제",
                message: "\(friend.name)님을 친구 목록에서 삭제하시겠습니까?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in
                completion(false)
            })
            
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
                reactor.action.onNext(.removeFriend(friend.friendshipId))
                completion(true)
            })
            
            self.present(alert, animated: true)
        }
        
        deleteAction.image = UIImage(systemName: "person.crop.circle.badge.minus")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
