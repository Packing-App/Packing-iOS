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
        let tableView = UITableView()
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.identifier)
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: FriendRequestCell.identifier)
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
        label.text = "친구 목록이 비어있습니다."
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        tableView.delegate = self

    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // 테이블 뷰 추가
        view.addSubview(tableView)
        
        // 액티비티 인디케이터 추가
        view.addSubview(activityIndicator)
        
        // 빈 상태 레이블 추가
        view.addSubview(emptyStateLabel)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        title = "내 친구"
        
        // 검색 컨트롤러 설정
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // 알림 버튼 추가
        let bellButton = UIBarButtonItem(
            image: UIImage(systemName: "bell"),
            style: .plain,
            target: self,
            action: #selector(bellButtonTapped)
        )
        navigationItem.rightBarButtonItem = bellButton
    }
    
    @objc private func bellButtonTapped() {
        // 벨 버튼 탭 시 친구 요청 화면으로 이동
        let requestsViewController = FriendRequestsViewController()
        let requestsReactor = FriendRequestsViewReactor()
        requestsViewController.reactor = requestsReactor
        
        navigationController?.pushViewController(requestsViewController, animated: true)
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
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { Reactor.Action.searchFriend($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 검색 취소 버튼 클릭 관찰
        searchController.searchBar.rx.cancelButtonClicked
            .map { Reactor.Action.clearSearch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .withLatestFrom(reactor.state.map { $0.friends }) { indexPath, friends in
                return (indexPath, friends)
            }
            .subscribe(onNext: { [weak self] indexPath, friends in
                if indexPath.row < friends.count {
                    let friend = friends[indexPath.row]
                    reactor.action.onNext(.removeFriend(friend.friendshipId))
                }
            })
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
        
        // 빈 상태 표시 처리 - 친구 목록
        reactor.state.map { $0.friends }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .map { !$0.isEmpty }
            .bind(to: emptyStateLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 빈 상태 텍스트 변경
        reactor.state.map { $0.viewMode }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] mode in
                switch mode {
                case .friendsList:
                    self?.emptyStateLabel.text = "친구 목록이 비어있습니다."
                case .searchResults:
                    self?.emptyStateLabel.text = "검색 결과가 없습니다."
                }
            })
            .disposed(by: disposeBag)
        
        // 검색 결과 상태에 따른 빈 상태 표시
        reactor.state.map { state -> Bool in
            if state.viewMode == .searchResults {
                return !state.searchResults.isEmpty
            }
            return true  // 검색 결과 모드가 아닐 때는 숨김 상태 유지
        }
        .observe(on: MainScheduler.instance)
        .distinctUntilChanged()
        .bind(to: emptyStateLabel.rx.isHidden)
        .disposed(by: disposeBag)
    }

    // MARK: - Private Methods
    private func setupDataSource(mode: FriendsViewReactor.ViewMode, reactor: FriendsViewReactor) {
        // 기존 데이터소스 구독 해제를 위해 disposeBag 초기화
        disposeBag = DisposeBag()
        
        // 다시 Action 바인딩 (disposeBag이 초기화되었으므로)
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { Reactor.Action.searchFriend($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .map { Reactor.Action.clearSearch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 기존 상태 바인딩 복원
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // 에러 처리 복원
        reactor.state.map { $0.error }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(error)
            })
            .disposed(by: disposeBag)
        
        // 모드에 따른 테이블뷰 데이터소스 설정
        // 중요: tableView.dataSource = nil을 명시적으로 설정
        tableView.dataSource = nil
        
        switch mode {
        case .friendsList:
            // 친구 목록 모드
            reactor.state.map { $0.friends }
                .distinctUntilChanged()
                .bind(to: tableView.rx.items(cellIdentifier: FriendCell.identifier, cellType: FriendCell.self)) { [weak self] index, friend, cell in
                    cell.configure(with: friend)
                    
                    // Use invite button to navigate to journey selection
                    cell.inviteButton.rx.tap
                        .subscribe(onNext: { [weak self] _ in
                            self?.showJourneySelectionForFriend(friend)
                        })
                        .disposed(by: cell.disposeBag)
                }
                .disposed(by: disposeBag)
            
        case .searchResults:
            // 검색 결과 모드
            reactor.state.map { $0.searchResults }
                .distinctUntilChanged()
                .bind(to: tableView.rx.items(cellIdentifier: FriendRequestCell.identifier, cellType: FriendRequestCell.self)) { [weak self] index, result, cell in
                    cell.configure(with: result)
                    
                    // 친구 상태에 따라 버튼 설정
                    if let friendshipStatus = result.friendshipStatus, friendshipStatus == .accepted {
                        // 이미 친구인 경우 - 삭제 버튼 표시
                        cell.actionButton.setTitle("친구 삭제", for: .normal)
                        cell.actionButton.setTitleColor(.red, for: .normal)
                        
                        if let friendshipId = result.friendshipId {
                            cell.actionButton.rx.tap
                                .map { Reactor.Action.removeFriend(friendshipId) }
                                .bind(to: reactor.action)
                                .disposed(by: cell.disposeBag)
                        }
                    } else if let friendshipStatus = result.friendshipStatus, friendshipStatus == .pending {
                        // 요청 중인 경우 - 비활성화된 버튼 표시
                        cell.actionButton.setTitle("요청 중", for: .normal)
                        cell.actionButton.isEnabled = false
                    } else {
                        // 친구 아닌 경우 - 요청 버튼 표시
                        cell.actionButton.setTitle("친구 요청", for: .normal)
                        cell.actionButton.setTitleColor(.systemBlue, for: .normal)
                        cell.actionButton.isEnabled = true
                        
                        cell.actionButton.rx.tap
                            .map { Reactor.Action.sendFriendRequest(result.email) }
                            .bind(to: reactor.action)
                            .disposed(by: cell.disposeBag)
                    }
                }
                .disposed(by: disposeBag)
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
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, completion) in
            guard let self = self, let reactor = self.reactor else {
                completion(false)
                return
            }
            
            let friend = reactor.currentState.friends[indexPath.row]
            reactor.action.onNext(.removeFriend(friend.friendshipId))
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}


// MARK: - FriendCell

class FriendCell: UITableViewCell {
    static let identifier = "FriendCell"
    
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
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("초대하기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        contentView.addSubview(introLabel)
        contentView.addSubview(inviteButton)
        
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
            nameLabel.trailingAnchor.constraint(equalTo: inviteButton.leadingAnchor, constant: -12),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            introLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            introLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            introLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            introLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            inviteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            inviteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            inviteButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            inviteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with friend: Friend) {
        nameLabel.text = friend.name
        emailLabel.text = friend.email
        introLabel.text = friend.intro ?? "자기소개가 없습니다."
        
        // 프로필 이미지 로드 (실제 구현에서는 이미지 라이브러리 사용)
        if let profileImageUrlString = friend.profileImage, let url = URL(string: profileImageUrlString) {
            // 실제 구현에서는 Kingfisher, SDWebImage 등의 라이브러리를 사용해 이미지 로드
            // 예: profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .gray
        }
    }
}

// MARK: - FriendRequestCell
class FriendRequestCell: UITableViewCell {
    static let identifier = "FriendRequestCell"
    
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
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        contentView.addSubview(actionButton)
        
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
            nameLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -12),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            actionButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with searchResult: FriendSearchResult) {
        nameLabel.text = searchResult.name
        emailLabel.text = searchResult.email
        
        // 프로필 이미지 로드 (실제 구현에서는 이미지 라이브러리 사용)
        if let profileImageUrlString = searchResult.profileImage, let url = URL(string: profileImageUrlString) {
            // 실제 구현에서는 Kingfisher, SDWebImage 등의 라이브러리를 사용해 이미지 로드
            // 예: profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .gray
        }
    }
    
}


// MARK: - JOURNEY SELECTION VIEW CONTROLLER


class JourneySelectionViewController: UIViewController {
    
    // MARK: - Properties
    var selectedFriend: Friend!
    private let journeyService = JourneyService()
    private var journeys: [Journey] = []
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 180)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TravelPlanCell.self, forCellWithReuseIdentifier: "TravelPlanCell")
        
        return collectionView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "여행 계획이 없습니다."
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadJourneys()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "여행 선택"
        
        titleLabel.text = "\(selectedFriend.name)님을 초대할 여행을 선택해주세요"
        
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        collectionView.rx.modelSelected(Journey.self)
            .subscribe(onNext: { [weak self] journey in
                self?.inviteFriendToJourney(journey: journey)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data Loading
    private func loadJourneys() {
        loadingIndicator.startAnimating()
        
        journeyService.getJourneys()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] journeys in
                self?.journeys = journeys
                self?.updateUI()
                self?.loadingIndicator.stopAnimating()
            }, onError: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
                self?.loadingIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI() {
        emptyLabel.isHidden = !journeys.isEmpty
        
        // Bind journeys to collection view
        Observable.just(journeys)
            .bind(to: collectionView.rx.items(cellIdentifier: "TravelPlanCell", cellType: TravelPlanCell.self)) { index, journey, cell in
                cell.configure(with: journey)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    private func inviteFriendToJourney(journey: Journey) {
        loadingIndicator.startAnimating()
        
        journeyService.inviteParticipant(journeyId: journey.id, email: selectedFriend.email)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                self?.loadingIndicator.stopAnimating()
                self?.showSuccessAlert(journey: journey)
            }, onError: { [weak self] error in
                self?.loadingIndicator.stopAnimating()
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Alerts
    private func showSuccessAlert(journey: Journey) {
        let alert = UIAlertController(
            title: "초대 완료",
            message: "\(selectedFriend.name)님을 '\(journey.title)' 여행에 초대했습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        present(alert, animated: true)
    }
}
