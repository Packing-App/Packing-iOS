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
        case respondToInvitation(String, Bool) // 초대 응답 액션
    }
    
    enum Mutation {
        case setNotifications([NotificationModel])
        case setSelectedTabIndex(Int)
        case updateNotification(String, Bool)
        case removeNotification(String)
        case setLoading(Bool)
        case setError(Error)
        case updateInvitationResponseStatus(String, Bool, Bool) // notificationId, isAccepted, isSuccess
    }
    
    struct State {
        var notifications: [NotificationModel] = []
        var filteredNotifications: [NotificationModel] = []
        var selectedTabIndex: Int = 0
        var isLoading: Bool = false
        var error: Error? = nil
        var unreadCount: Int = 0
        var notificationTypes: [NotificationType?] = [nil, .invitation, .weather, .reminder]
        var lastRespondedInvitation: (id: String, accepted: Bool, success: Bool)? = nil
        
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
                        // 응답 상태 업데이트 (성공/실패 여부 포함)
                        let statusMutation = Mutation.updateInvitationResponseStatus(notificationId, accept, success)
                        
                        if success {
                            // 성공 시 알림을 읽음 상태로 변경
                            return Observable.concat([
                                Observable.just(statusMutation),
                                Observable.just(Mutation.updateNotification(notificationId, true))
                            ])
                        } else {
                            // 실패 시 상태만 업데이트
                            return Observable.just(statusMutation)
                        }
                    }
                    .catch { error in
                        print("Journey service error: \(error.localizedDescription)")
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
                // 불변 모델을 업데이트하는 개념적 접근 방식
                var updatedNotifications = newState.notifications
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
                
                // 읽지 않은 알림 수 재계산
                newState.unreadCount = newState.notifications.filter { !$0.isRead }.count
                
                // 필요한 경우 필터링된 목록 업데이트
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
            
        case let .updateInvitationResponseStatus(id, accepted, success):
            // 가장 최근에 응답한 초대장 정보 저장
            newState.lastRespondedInvitation = (id: id, accepted: accepted, success: success)
        }
        
        return newState
    }
}
