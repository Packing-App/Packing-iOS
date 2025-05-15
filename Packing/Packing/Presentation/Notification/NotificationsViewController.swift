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
class NotificationsViewController: UIViewController, View, InvitationCallbackDelegate {
    var disposeBag = DisposeBag()
    
    // UI Components
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateView = UIView()
    private var loadingAlert: UIAlertController?
    
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
        // 초기 데이터 로드
        reactor?.action.onNext(.fetchNotifications)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarAppearance()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "알림".localized
        view.backgroundColor = .systemGroupedBackground
        
        setupNavigationBar()
        
        setupTableView()
        setupEmptyStateView()
        setupActivityIndicator()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "모두 읽음".localized,
            style: .plain,
            target: self,
            action: #selector(markAllAsRead)
        )
    }
    
    private func setupTableView() {
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.refreshControl = refreshControl
        
        // iOS 15 이상에서 테이블뷰 스타일 적용
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyStateView() {
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // 이미지 뷰 추가
        let imageView = UIImageView(image: UIImage(systemName: "bell.slash"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        
        emptyStateView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // 라벨 추가
        let label = UILabel()
        label.text = "알림이 없습니다".localized
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        
        emptyStateView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
        ])
        
        // 설명 라벨 추가
        let descriptionLabel = UILabel()
        descriptionLabel.text = "여행 초대 및 정보 알림이 여기에 표시됩니다".localized
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .tertiaryLabel
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.numberOfLines = 0
        
        emptyStateView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
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
        navigationController?.navigationBar.tintColor = .black

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
    
    // MARK: - InvitationCallbackDelegate 구현
    func handleInvitationResponse(notificationId: String, accept: Bool) {
        
        // 해당 셀의 버튼 비활성화 (UI 피드백)
        if let index = reactor?.currentState.notifications.firstIndex(where: { $0.id == notificationId }),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? NotificationTableViewCell {
            // 버튼 비활성화
            cell.acceptButton.isEnabled = false
            cell.rejectButton.isEnabled = false
            cell.acceptButton.alpha = 0.5
            cell.rejectButton.alpha = 0.5
        }
        
        // 로딩 표시
        showLoadingAlert(for: accept)
        
        // 액션 실행
        reactor?.action.onNext(.respondToInvitation(notificationId, accept))
    }
    
    // 로딩 알림 표시
    private func showLoadingAlert(for accept: Bool) {
        // 기존 알림이 있으면 먼저 닫기
        if let alert = loadingAlert {
            alert.dismiss(animated: false)
        }
        
        let alert = UIAlertController(
            title: nil,
            message: accept ? "초대를 수락하는 중...".localized : "초대를 거절하는 중...".localized,
            preferredStyle: .alert
        )
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        
        // 로딩 인디케이터 위치 조정
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40)
        ])
        
        loadingAlert = alert
        present(alert, animated: true)
    }
    
    // 로딩 알림 닫기
    private func dismissLoadingAlert() {
        loadingAlert?.dismiss(animated: true) {
            self.loadingAlert = nil
        }
    }
    
    // 초대장 응답 결과 표시
    private func showInvitationResponseResult(id: String, accepted: Bool, success: Bool) {
        // 로딩 알림 닫기
        dismissLoadingAlert()
        
        if success {
            // 성공 메시지
            let title = accepted ? "초대 수락됨".localized : "초대 거절됨".localized
            let message = accepted ? "여행에 참여하셨습니다.".localized : "초대가 거절되었습니다.".localized
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인".localized, style: .default))
            present(alert, animated: true)
            
            // 알림 새로고침
            reactor?.action.onNext(.fetchNotifications)
        } else {
            // 실패 메시지
            let alert = UIAlertController(
                title: "오류".localized,
                message: "요청을 처리하는 중 문제가 발생했습니다. 다시 시도해주세요.".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인".localized, style: .default))
            present(alert, animated: true)
        }
    }
    
    // MARK: - ReactorKit Setup
    func bind(reactor: NotificationsReactor) {
        // Action bindings
        
        // Pull to refresh
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.fetchNotifications }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State bindings
        
        // Notifications list
        reactor.state.map { $0.notifications }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .do(onNext: { notifications in
                print("Notifications count: \(notifications.count)")
            })
            .bind(to: tableView.rx.items) { [weak self] tableView, row, notification in
                let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! NotificationTableViewCell
                
                // 셀 구성
                cell.configure(with: notification)
                
                // 델리게이트 설정
                cell.invitationCallbackDelegate = self
                
                // 디버그 로깅
                if notification.type == .invitation {
                    print("Setting up invitation cell at row \(row), ID: \(notification.id ?? "unknown")")
                }
                
                return cell
            }
            .disposed(by: disposeBag)
        
        // Empty state
        reactor.state.map { $0.notifications.isEmpty && !$0.isLoading }
            .observe(on: MainScheduler.instance)
            .bind(to: emptyStateView.rx.isHidden.mapObserver { !$0 })
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
                // 로딩 알림 닫기
                self?.dismissLoadingAlert()
                
                let alert = UIAlertController(
                    title: "오류".localized,
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인".localized, style: .default))
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
                (indexPath, state.notifications[indexPath.row])
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
