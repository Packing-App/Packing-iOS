//
//  NotificationsReactor.swift
//  Packing
//
//  Created by 이융의 on 4/30/25.
//

import Foundation
import UIKit
import ReactorKit
import RxSwift
import RxCocoa


// MARK: - NotificationsReactor
final class NotificationsReactor: Reactor {
    enum Action {
        case fetchNotifications
        case markAsRead(String)
        case markAllAsRead
        case deleteNotification(String)
        case selectTab(Int)
    }
    
    enum Mutation {
        case setNotifications([NotificationModel])
        case setSelectedTabIndex(Int)
        case updateNotification(String, Bool)
        case removeNotification(String)
        case setLoading(Bool)
        case setError(Error)
    }
    
    struct State {
        var notifications: [NotificationModel] = []
        var filteredNotifications: [NotificationModel] = []
        var selectedTabIndex: Int = 0
        var isLoading: Bool = false
        var error: Error? = nil
        var unreadCount: Int = 0
        var notificationTypes: [NotificationType?] = [nil, .invitation, .weather, .reminder]
        
        var selectedType: NotificationType? {
            // 안전하게 인덱스 범위 확인
            guard selectedTabIndex >= 0 && selectedTabIndex < notificationTypes.count else {
                return nil
            }
            return notificationTypes[selectedTabIndex]
        }
    }
    
    let initialState: State = State()
    private let notificationService: NotificationServiceProtocol
    private let disposeBag = DisposeBag()
    
    init(notificationService: NotificationServiceProtocol) {
        self.notificationService = notificationService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchNotifications:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                notificationService.getNotifications()
                    .map { Mutation.setNotifications($0) }
                    .catch { error in
                        return Observable.just(Mutation.setError(error))
                    },
                
                Observable.just(Mutation.setLoading(false))
            ])
            
        case let .markAsRead(id):
            return notificationService.markNotificationAsRead(id: id)
                .filter { $0 }
                .map { _ in Mutation.updateNotification(id, true) }
                .catch { error in
                    return Observable.just(Mutation.setError(error))
                }
            
        case .markAllAsRead:
            return notificationService.markAllNotificationsAsRead()
                .filter { $0 }
                .flatMap { _ in self.notificationService.getNotifications() }
                .map { Mutation.setNotifications($0) }
                .catch { error in
                    return Observable.just(Mutation.setError(error))
                }
                
        case let .deleteNotification(id):
            return notificationService.deleteNotification(id: id)
                .filter { $0 }
                .map { _ in Mutation.removeNotification(id) }
                .catch { error in
                    return Observable.just(Mutation.setError(error))
                }
                
        case let .selectTab(index):
            // 안전하게 인덱스 범위 확인
            let safeIndex = max(0, min(index, initialState.notificationTypes.count - 1))
            return Observable.just(Mutation.setSelectedTabIndex(safeIndex))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setNotifications(notifications):
            newState.notifications = notifications
            newState.unreadCount = notifications.filter { !$0.isRead }.count
            
            // Apply existing filter if any
            if let selectedType = newState.selectedType {
                newState.filteredNotifications = notifications.filter { $0.type == selectedType }
            } else {
                newState.filteredNotifications = notifications
            }
            
        case let .setSelectedTabIndex(index):
            // 안전하게 인덱스 범위 확인
            newState.selectedTabIndex = max(0, min(index, newState.notificationTypes.count - 1))
            
            if let type = newState.selectedType {
                newState.filteredNotifications = state.notifications.filter { $0.type == type }
            } else {
                newState.filteredNotifications = state.notifications
            }
            
        case let .updateNotification(id, isRead):
            if let index = newState.notifications.firstIndex(where: { $0.id == id }) {
                // In a real app, you'd need to handle immutable models properly
                // This is a conceptual approach
                var updatedNotifications = newState.notifications
                // We need to create a new notification with isRead updated
                // Since NotificationModel is immutable, we'd need a proper way to do this
                updatedNotifications[index] = NotificationModel(
                    id: updatedNotifications[index].id,
                    userId: updatedNotifications[index].userId,
                    journeyId: updatedNotifications[index].journeyId,
                    type: updatedNotifications[index].type,
                    content: updatedNotifications[index].content,
                    isRead: true,
                    scheduledAt: updatedNotifications[index].scheduledAt,
                    createdAt: updatedNotifications[index].createdAt
                )
                newState.notifications = updatedNotifications
                
                // Recalculate unread count
                newState.unreadCount = newState.notifications.filter { !$0.isRead }.count
                
                // Update filtered list if necessary
                if let type = newState.selectedType {
                    newState.filteredNotifications = newState.notifications.filter { $0.type == type }
                } else {
                    newState.filteredNotifications = newState.notifications
                }
            }
            
        case let .removeNotification(id):
            newState.notifications.removeAll { $0.id == id }
            newState.filteredNotifications.removeAll { $0.id == id }
            newState.unreadCount = newState.notifications.filter { !$0.isRead }.count
            
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .setError(error):
            newState.error = error
        }
        
        return newState
    }
}

// MARK: - Custom UI Components

// MARK: - NotificationTableViewCell
class NotificationTableViewCell: UITableViewCell {
    static let identifier = "NotificationTableViewCell"
    
    // UI Components
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let contentLabel = UILabel()
    private let unreadIndicator = UIView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Container view setup
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
        
        // Unread indicator setup
        unreadIndicator.backgroundColor = .systemBlue
        unreadIndicator.layer.cornerRadius = 4
        containerView.addSubview(unreadIndicator)
        
        unreadIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unreadIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            unreadIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            unreadIndicator.widthAnchor.constraint(equalToConstant: 8),
            unreadIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        // Title Label setup
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        containerView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: unreadIndicator.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
        
        // Date Label setup
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .secondaryLabel
        containerView.addSubview(dateLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        // Content Label setup
        contentLabel.font = UIFont.preferredFont(forTextStyle: .body)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 2
        containerView.addSubview(contentLabel)
        
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with notification: NotificationModel) {
        // Set notification type as title
        switch notification.type {
        case .invitation:
            titleLabel.text = "초대장"
        case .weather:
            titleLabel.text = "날씨 알림"
        case .reminder:
            titleLabel.text = "리마인더"
        }
        
        // Date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateLabel.text = dateFormatter.string(from: notification.createdAt)
        
        // Content
        contentLabel.text = notification.content
        
        // Unread indicator
        unreadIndicator.isHidden = notification.isRead
    }
}
