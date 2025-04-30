//
//  NotificationsViewController.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import UIKit
import RxSwift
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
    
    // Services
    private var journeyService: JourneyServiceProtocol
    
    // MARK: - Initialization
    init(reactor: NotificationsReactor, journeyService: JourneyServiceProtocol) {
        self.journeyService = journeyService
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
        tableView.delegate = self
        
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
    
    // MARK: - Journey Invitation Response
    private func respondToInvitation(notificationId: String, accept: Bool) {
        print("Responding to invitation: \(notificationId), accept: \(accept)") // Debug log
        
        // Show loading indicator
        let loadingAlert = UIAlertController(
            title: accept ? "초대 수락 중..." : "초대 거절 중...",
            message: "잠시만 기다려주세요.",
            preferredStyle: .alert
        )
        present(loadingAlert, animated: true)
        
        journeyService.respondToInvitation(notificationId: notificationId, accept: accept)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                print("API response received: \(success)") // Debug log
                
                // Dismiss loading alert
                loadingAlert.dismiss(animated: true) {
                    if success {
                        // Show success message
                        let title = accept ? "초대 수락됨" : "초대 거절됨"
                        let message = accept ? "여행에 참여하셨습니다." : "초대가 거절되었습니다."
                        
                        let alert = UIAlertController(
                            title: title,
                            message: message,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self?.present(alert, animated: true)
                        
                        // Mark notification as read and refresh the list
                        if let reactor = self?.reactor {
                            reactor.action.onNext(.markAsRead(notificationId))
                            reactor.action.onNext(.fetchNotifications)
                        }
                    } else {
                        // Show error message
                        let alert = UIAlertController(
                            title: "오류",
                            message: "요청을 처리하는 중 문제가 발생했습니다. 다시 시도해주세요.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }, onError: { [weak self] error in
                print("API error: \(error.localizedDescription)") // Debug log
                
                // Dismiss loading alert and show error
                loadingAlert.dismiss(animated: true) {
                    let alert = UIAlertController(
                        title: "오류",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self?.present(alert, animated: true)
                }
            })
            .disposed(by: disposeBag)
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
                print("Filtered notifications count: \(notifications.count)") // Debug log
            })
            .bind(to: tableView.rx.items(cellIdentifier: NotificationTableViewCell.identifier, cellType: NotificationTableViewCell.self)) { [weak self] indexPath, notification, cell in
                cell.configure(with: notification)
                
                // Set up invitation response callbacks
                if notification.type == .invitation, let id = notification.id {
                    print("Setting up callbacks for invitation notification: \(id)") // Debug log
                    
                    // Clear existing callbacks
                    cell.onAcceptTapped = nil
                    cell.onRejectTapped = nil
                    
                    // Set new callbacks
                    cell.onAcceptTapped = { [weak self] in
                        print("Accept callback triggered for notification: \(id)") // Debug log
                        self?.respondToInvitation(notificationId: id, accept: true)
                    }
                    
                    cell.onRejectTapped = { [weak self] in
                        print("Reject callback triggered for notification: \(id)") // Debug log
                        self?.respondToInvitation(notificationId: id, accept: false)
                    }
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
        
        // TableView item selection
        tableView.rx.modelSelected(NotificationModel.self)
            .bind(onNext: { [weak self] notification in
                if !notification.isRead {
                    if let id = notification.id {
                        reactor.action.onNext(.markAsRead(id))
                    }
                }
                
                // Deselect row
                if let selectedIndexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        // Swipe to delete
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
    }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let reactor = reactor,
              let notificationCell = cell as? NotificationTableViewCell,
              let notification = reactor.currentState.filteredNotifications[safe: indexPath.row],
              notification.type == .invitation,
              let id = notification.id else {
            return
        }
        
        // Make sure we update the callbacks when cell is about to display
        notificationCell.onAcceptTapped = { [weak self] in
            print("Accept callback triggered in willDisplay for notification: \(id)") // Debug log
            self?.respondToInvitation(notificationId: id, accept: true)
        }
        
        notificationCell.onRejectTapped = { [weak self] in
            print("Reject callback triggered in willDisplay for notification: \(id)") // Debug log
            self?.respondToInvitation(notificationId: id, accept: false)
        }
    }
}

// MARK: - Date Formatter Helper
extension DateFormatter {
    static let notificationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
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
