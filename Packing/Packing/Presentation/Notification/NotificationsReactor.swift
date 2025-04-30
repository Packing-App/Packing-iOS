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
        case respondToInvitation(String, Bool) // Added invitation response action
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
    private let journeyService: JourneyServiceProtocol
    private let disposeBag = DisposeBag()
    
    init(notificationService: NotificationServiceProtocol, journeyService: JourneyServiceProtocol) {
        self.notificationService = notificationService
        self.journeyService = journeyService
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
            
        case let .respondToInvitation(notificationId, accept):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                
                journeyService.respondToInvitation(notificationId: notificationId, accept: accept)
                    .flatMap { success -> Observable<Mutation> in
                        if success {
                            // If successful, mark the notification as read
                            return Observable.just(Mutation.updateNotification(notificationId, true))
                        } else {
                            // Handle failure
                            return Observable.just(Mutation.setError(NSError(
                                domain: "JourneyServiceError",
                                code: 1001,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to respond to invitation"]
                            )))
                        }
                    }
                    .catch { error in
                        return Observable.just(Mutation.setError(error))
                    },
                
                Observable.just(Mutation.setLoading(false))
            ])
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
