//
//  NotificationsViewController.swift
//  Packing
//
//  Created by 이융의 on 5/1/25.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationsViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let notificationService: NotificationServiceProtocol
    private let journeyService: JourneyServiceProtocol
    
    private var notifications: [NotificationModel] = []
    private var filteredNotifications: [NotificationModel] = []
    private var selectedTabIndex: Int = 0
    private let notificationTypes: [NotificationType?] = [nil, .invitation, .weather, .reminder]
    
    // MARK: - UI Components
    private let segmentedControl = UISegmentedControl()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel = UILabel()
    private var loadingAlert: UIAlertController?
    
    // MARK: - Initialization
    init(notificationService: NotificationServiceProtocol, journeyService: JourneyServiceProtocol) {
        self.notificationService = notificationService
        self.journeyService = journeyService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindEvents()
        fetchNotifications()
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
            action: #selector(markAllAsReadTapped)
        )
    }
    
    private func setupSegmentedControl() {
        segmentedControl.insertSegment(withTitle: "전체", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "초대장", at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: "날씨", at: 2, animated: false)
        segmentedControl.insertSegment(withTitle: "리마인더", at: 3, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
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
        tableView.dataSource = self
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
    
    // MARK: - Event Bindings
    private func bindEvents() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    // MARK: - Actions
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedTabIndex = sender.selectedSegmentIndex
        filterNotifications()
    }
    
    @objc private func markAllAsReadTapped() {
        setLoading(true)
        
        notificationService.markAllNotificationsAsRead()
            .observe(on: MainScheduler.instance) // 메인 스레드에서 UI 업데이트 보장
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.fetchNotifications()
                }
            }, onError: { [weak self] error in
                self?.setLoading(false)
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func refreshData() {
        fetchNotifications()
    }
    
    // MARK: - Data Methods
    private func fetchNotifications() {
        setLoading(true)
        
        notificationService.getNotifications()
            .observe(on: MainScheduler.instance) // 메인 스레드에서 UI 업데이트 보장
            .subscribe(onNext: { [weak self] notifications in
                self?.notifications = notifications
                self?.filterNotifications()
                self?.setLoading(false)
            }, onError: { [weak self] error in
                self?.setLoading(false)
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    private func filterNotifications() {
        let selectedType = notificationTypes[selectedTabIndex]
        
        if let type = selectedType {
            filteredNotifications = notifications.filter { $0.type == type }
        } else {
            filteredNotifications = notifications
        }
        
        updateUI()
    }
    
    private func markAsRead(_ id: String) {
        notificationService.markNotificationAsRead(id: id)
            .observe(on: MainScheduler.instance) // 메인 스레드에서 UI 업데이트 보장
            .subscribe(onNext: { [weak self] success in
                if success {
                    if let index = self?.notifications.firstIndex(where: { $0.id == id }) {
                        // Create a new notification model with isRead = true
                        let oldNotification = self?.notifications[index]
                        if let old = oldNotification, let id = old.id {
                            let updatedNotification = NotificationModel(
                                id: id,
                                userId: old.userId,
                                journeyId: old.journeyId,
                                type: old.type,
                                content: old.content,
                                isRead: true,
                                scheduledAt: old.scheduledAt,
                                createdAt: old.createdAt
                            )
                            self?.notifications[index] = updatedNotification
                            self?.filterNotifications()
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func deleteNotification(_ id: String) {
        notificationService.deleteNotification(id: id)
            .observe(on: MainScheduler.instance) // 메인 스레드에서 UI 업데이트 보장
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.notifications.removeAll { $0.id == id }
                    self?.filterNotifications()
                }
            }, onError: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Invitation Response
    func handleInvitationResponse(notificationId: String, accept: Bool) {
        print("✅ handleInvitationResponse called: ID=\(notificationId), accept=\(accept)")
        
        // 메인 스레드에서 UI 업데이트
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Disable the buttons in the cell for better UX
            if let index = self.filteredNotifications.firstIndex(where: { $0.id == notificationId }),
               let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NotificationTableViewCell {
                cell.acceptButton.isEnabled = false
                cell.rejectButton.isEnabled = false
                cell.acceptButton.alpha = 0.5
                cell.rejectButton.alpha = 0.5
            }
            
            // Show loading alert
            self.showLoadingAlert(for: accept)
        }
        
        // Process the invitation response
        journeyService.respondToInvitation(notificationId: notificationId, accept: accept)
            .observe(on: MainScheduler.instance) // 메인 스레드에서 UI 업데이트 보장
            .subscribe(onNext: { [weak self] success in
                // Hide loading indicator
                self?.dismissLoadingAlert()
                
                if success {
                    // Mark notification as read
                    self?.markAsRead(notificationId)
                    
                    // Show success message
                    let title = accept ? "초대 수락됨" : "초대 거절됨"
                    let message = accept ? "여행에 참여하셨습니다." : "초대가 거절되었습니다."
                    self?.showAlert(title: title, message: message)
                    
                    // Refresh notifications
                    self?.fetchNotifications()
                } else {
                    // Show error message
                    self?.showAlert(title: "오류", message: "요청을 처리하는 중 문제가 발생했습니다. 다시 시도해주세요.")
                    
                    // Re-enable buttons on main thread
                    DispatchQueue.main.async {
                        if let index = self?.filteredNotifications.firstIndex(where: { $0.id == notificationId }),
                           let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NotificationTableViewCell {
                            cell.acceptButton.isEnabled = true
                            cell.rejectButton.isEnabled = true
                            cell.acceptButton.alpha = 1.0
                            cell.rejectButton.alpha = 1.0
                        }
                    }
                }
            }, onError: { [weak self] error in
                self?.dismissLoadingAlert()
                self?.showError(error)
                
                // Re-enable buttons on main thread
                DispatchQueue.main.async {
                    if let index = self?.filteredNotifications.firstIndex(where: { $0.id == notificationId }),
                       let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NotificationTableViewCell {
                        cell.acceptButton.isEnabled = true
                        cell.rejectButton.isEnabled = true
                        cell.acceptButton.alpha = 1.0
                        cell.rejectButton.alpha = 1.0
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Helpers
    private func updateUI() {
        // UI 업데이트는 항상 메인 스레드에서 수행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.emptyStateLabel.isHidden = !self.filteredNotifications.isEmpty
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        // UI 업데이트는 항상 메인 스레드에서 수행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if isLoading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func showLoadingAlert(for accept: Bool) {
        // UI 업데이트는 항상 메인 스레드에서 수행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Dismiss any existing alert
            if let alert = self.loadingAlert {
                alert.dismiss(animated: false)
            }
            
            self.loadingAlert = UIAlertController(
                title: accept ? "초대 수락 중..." : "초대 거절 중...",
                message: "잠시만 기다려주세요.",
                preferredStyle: .alert
            )
            
            if let alert = self.loadingAlert {
                self.present(alert, animated: true)
            }
        }
    }
    
    private func dismissLoadingAlert() {
        // UI 업데이트는 항상 메인 스레드에서 수행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.loadingAlert?.dismiss(animated: true) {
                self.loadingAlert = nil
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        // UI 업데이트는 항상 메인 스레드에서 수행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    private func showError(_ error: Error) {
        showAlert(title: "오류", message: error.localizedDescription)
    }
}

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: IndexPath(row: indexPath.row, section: 0)) as! NotificationTableViewCell
        
        // 인덱스 범위 확인
        guard indexPath.row < filteredNotifications.count else {
            print("⚠️ Error: Index out of range in cellForRowAt")
            return cell
        }
        
        let notification = filteredNotifications[indexPath.row]
        
        // 명확한 디버깅 메시지 추가
        print("🔍 Creating cell at row \(indexPath.row) for notification ID: \(notification.id ?? "nil")")
        
        // ID가 없는 알림 확인
        if notification.id == nil {
            print("⚠️ Warning: Notification at index \(indexPath.row) has no ID")
        }
        
        // 셀 구성
        cell.configure(with: notification)
        
        // 셀에 셀 태그로 인덱스 저장 (추가 식별 방법)
        cell.tag = indexPath.row
        
        // 클로저 설정 전에 notificationId 확인
        if cell.notificationId == nil && notification.id != nil {
            print("⚠️ Warning: Cell notificationId is nil after configure!")
            cell.notificationId = notification.id // 강제로 다시 설정
        }
        
        // 버튼 직접 추가 확인
        if notification.type == .invitation {
            cell.responseButtonsContainer.isHidden = false
        } else {
            cell.responseButtonsContainer.isHidden = true
        }
        
        // 콜백 핸들러 설정
        cell.invitationCallbackHandler = { [weak self] notificationId, accept in
            if notificationId.isEmpty {
                print("⚠️ Error: Empty notification ID in callback")
                
                // 인덱스로 ID 찾기 시도
                if let rowIndex = cell.tag as? Int,
                   rowIndex < self?.filteredNotifications.count ?? 0,
                   let recoveredId = self?.filteredNotifications[rowIndex].id {
                    print("🔄 Recovered ID from cell tag: \(recoveredId)")
                    self?.handleInvitationResponse(notificationId: recoveredId, accept: accept)
                } else {
                    print("❌ Could not recover notification ID")
                }
                return
            }
            
            print("✅ Invitation callback with valid ID: \(notificationId)")
            self?.handleInvitationResponse(notificationId: notificationId, accept: accept)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let id = filteredNotifications[indexPath.row].id {
                deleteNotification(id)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = filteredNotifications[indexPath.row]
        if !notification.isRead, let id = notification.id {
            markAsRead(id)
        }
    }
}
