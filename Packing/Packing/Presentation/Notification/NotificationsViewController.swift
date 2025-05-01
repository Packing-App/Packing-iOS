//
//  NotificationsViewController.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

// MARK: - NotificationsViewController
class NotificationsViewController: UIViewController, View {
    var disposeBag = DisposeBag()
    
    // UI Components
    private let segmentedControl = UISegmentedControl()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel = UILabel()
    
    // MARK: - Initialization
    init(reactor: NotificationsReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "알림"
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupSegmentedControl()
        setupTableView()
        setupEmptyStateLabel()
        setupActivityIndicator()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "모두 읽음",
            style: .plain,
            target: self,
            action: #selector(markAllAsRead)
        )
    }
    
    private func setupSegmentedControl() {
        segmentedControl.insertSegment(withTitle: "전체", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "초대장", at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: "날씨", at: 2, animated: false)
        segmentedControl.insertSegment(withTitle: "리마인더", at: 3, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupTableView() {
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyStateLabel() {
        emptyStateLabel.text = "알림이 없습니다"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        emptyStateLabel.isHidden = true
        
        view.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func markAllAsRead() {
        reactor?.action.onNext(.markAllAsRead)
    }
    
    // MARK: - ReactorKit Setup
    func bind(reactor: NotificationsReactor) {
        // Action bindings
        
        // Tab selection
        segmentedControl.rx.selectedSegmentIndex
            .map { Reactor.Action.selectTab($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Pull to refresh
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.fetchNotifications }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Initial data fetch
        reactor.action.onNext(.fetchNotifications)
        
        // State bindings
        
        // Notifications list
        reactor.state.map { $0.filteredNotifications }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .do(onNext: { notifications in
                print("Filtered notifications count: \(notifications.count)")
            })
            .bind(to: tableView.rx.items(cellIdentifier: NotificationTableViewCell.identifier)) { [weak self] indexPath, notification, cell in
                guard let notificationCell = cell as? NotificationTableViewCell else { return }
                notificationCell.configure(with: notification)

                if notification.type == .invitation, let id = notification.id {
                    print("Setting up invitation callbacks for cell at \(indexPath), ID: \(id)")
                    
                    // 콜백 설정
                    notificationCell.onAcceptTapped = {
                        print("Accept button tapped for notification: \(id)")
                        self?.handleInvitationResponse(notificationId: id, accept: true)
                    }
                    
                    notificationCell.onRejectTapped = {
                        print("Reject button tapped for notification: \(id)")
                        self?.handleInvitationResponse(notificationId: id, accept: false)
                    }
                } else {
                    // 초대장이 아닌 경우 콜백 제거
                    notificationCell.onAcceptTapped = nil
                    notificationCell.onRejectTapped = nil
                }
            }
            .disposed(by: disposeBag)
        
        // Empty state
        reactor.state.map { $0.filteredNotifications.isEmpty && !$0.isLoading }
            .observe(on: MainScheduler.instance)
            .bind(to: emptyStateLabel.rx.isHidden.mapObserver { !$0 })
            .disposed(by: disposeBag)
        
        // Loading state
        reactor.state.map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        // Error handling
        reactor.state.map { $0.error as AnyObject? }
            .observe(on: MainScheduler.instance)
            .filterNil()
            .distinctUntilChanged { $0 === $1 }
            .bind(onNext: { [weak self] error in
                let alert = UIAlertController(
                    title: "오류",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        // TableView item selection - 아이템 선택 시 읽음 처리
        tableView.rx.modelSelected(NotificationModel.self)
            .bind(onNext: { [weak self] notification in
                if !notification.isRead {
                    if let id = notification.id {
                        reactor.action.onNext(.markAsRead(id))
                    }
                }
                
                // 선택 해제
                if let selectedIndexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        // 스와이프로 삭제
        tableView.rx.itemDeleted
            .withLatestFrom(reactor.state) { indexPath, state in
                (indexPath, state.filteredNotifications[indexPath.row])
            }
            .bind(onNext: { _, notification in
                if let id = notification.id {
                    reactor.action.onNext(.deleteNotification(id))
                }
            })
            .disposed(by: disposeBag)
        
        // 초대 응답 결과 처리
        reactor.state.map { $0.lastRespondedInvitation }
            .distinctUntilChanged { $0?.id == $1?.id }
            .filterNil()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] responseInfo in
                // 응답 결과에 따른 알림 표시
                self?.showInvitationResponseResult(
                    id: responseInfo.id,
                    accepted: responseInfo.accepted,
                    success: responseInfo.success
                )
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 초대장 응답 처리
    private func handleInvitationResponse(notificationId: String, accept: Bool) {
        print("Handling invitation response: \(notificationId), accept: \(accept)")
        
        // 해당 셀의 버튼 비활성화 (UI 피드백)
        if let index = reactor?.currentState.filteredNotifications.firstIndex(where: { $0.id == notificationId }),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NotificationTableViewCell {
            // 버튼 비활성화
            cell.acceptButton.isEnabled = false
            cell.rejectButton.isEnabled = false
            cell.acceptButton.alpha = 0.5
            cell.rejectButton.alpha = 0.5
        }
        
        // 로딩 표시
        let loadingAlert = UIAlertController(
            title: accept ? "초대 수락 중..." : "초대 거절 중...",
            message: "잠시만 기다려주세요.",
            preferredStyle: .alert
        )
        present(loadingAlert, animated: true) {
            // 로딩 표시 후 액션 실행
            self.reactor?.action.onNext(.respondToInvitation(notificationId, accept))
            
            // 2초 후 로딩 알림 닫기 (실제로는 Reactor의 상태 변화로 처리할 수 있음)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                loadingAlert.dismiss(animated: true)
            }
        }
    }
    
    // 초대장 응답 결과 표시
    private func showInvitationResponseResult(id: String, accepted: Bool, success: Bool) {
        if success {
            // 성공 메시지
            let title = accepted ? "초대 수락됨" : "초대 거절됨"
            let message = accepted ? "여행에 참여하셨습니다." : "초대가 거절되었습니다."
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            
            // 알림 새로고침
            reactor?.action.onNext(.fetchNotifications)
        } else {
            // 실패 메시지
            let alert = UIAlertController(
                title: "오류",
                message: "요청을 처리하는 중 문제가 발생했습니다. 다시 시도해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - Observable Extensions
extension Observable where Element == Bool {
    func not() -> Observable<Bool> {
        return self.map { !$0 }
    }
}

extension ObservableType {
    func filterNil<T>() -> Observable<T> where Element == Optional<T> {
        return self.filter { $0 != nil }.map { $0! }
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
