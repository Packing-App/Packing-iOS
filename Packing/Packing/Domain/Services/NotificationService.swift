//
//  NotificationService.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import Foundation
import RxSwift

protocol NotificationServiceProtocol {
    // 알림 목록 조회
    func getNotifications() -> Observable<[NotificationModel]>
    
    // 알림 읽음 처리
    func markNotificationAsRead(id: String) -> Observable<Bool>
    
    // 모든 알림 읽음 처리
    func markAllNotificationsAsRead() -> Observable<Bool>
    
    // 알림 삭제
    func deleteNotification(id: String) -> Observable<Bool>
    
    // 읽지 않은 알림 수 조회 (추가 기능)
    func getUnreadCount() -> Observable<Int>
    
    // 테스트용 여행 리마인더 알림 생성
    func createJourneyReminder(journeyId: String) -> Observable<NotificationModel>
    
    // 테스트용 날씨 알림 생성
    func createWeatherAlert(journeyId: String) -> Observable<NotificationModel>
}

class NotificationService: NotificationServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    // 알림 목록 조회
    func getNotifications() -> Observable<[NotificationModel]> {
        return apiClient.requestWithDateDecoding(NotificationEndpoint.getNotifications)
            .map { (response: APIResponse<[NotificationModel]>) -> [NotificationModel] in
                print("알림 목록 조회 응답: \(response.message)")
                return response.data ?? []
            }
            .catch { error in
                print("알림 목록 조회 오류: \(error.localizedDescription)")
                return .just([])
            }
    }
    
    // 알림 읽음 처리
    func markNotificationAsRead(id: String) -> Observable<Bool> {
        return apiClient.request(NotificationEndpoint.markNotificationAsRead(id: id))
            .map { (response: APIResponse<NotificationModel>) -> Bool in
                print("알림 읽음 처리 응답: \(response.message)")
                return response.success
            }
            .catch { error in
                print("알림 읽음 처리 오류: \(error.localizedDescription)")
                return .just(false)
            }
    }
    
    // 모든 알림 읽음 처리
    func markAllNotificationsAsRead() -> Observable<Bool> {
        return apiClient.request(NotificationEndpoint.markAllNotificationsAsRead)
            .map { (response: APIResponse<EmptyResponse>) -> Bool in
                print("모든 알림 읽음 처리 응답: \(response.message)")
                return response.success
            }
            .catch { error in
                print("모든 알림 읽음 처리 오류: \(error.localizedDescription)")
                return .just(false)
            }
    }
    
    // 알림 삭제
    func deleteNotification(id: String) -> Observable<Bool> {
        return apiClient.request(NotificationEndpoint.deleteNotification(id: id))
            .map { (response: APIResponse<EmptyResponse>) -> Bool in
                print("알림 삭제 응답: \(response.message)")
                return response.success
            }
            .catch { error in
                print("알림 삭제 오류: \(error.localizedDescription)")
                return .just(false)
            }
    }
    
    // 읽지 않은 알림 수 조회
    func getUnreadCount() -> Observable<Int> {
        return apiClient.request(NotificationEndpoint.getUnreadCount)
            .map { (response: APIResponse<UnreadCountResponse>) -> Int in
                print("읽지 않은 알림 수 조회 응답: \(response.message)")
                return response.data?.count ?? 0
            }
            .catch { error in
                
                print("읽지 않은 알림 수 조회 오류: \(error.localizedDescription)")
                return .just(0)
            }
    }
    
    // 테스트용 여행 리마인더 알림 생성
    func createJourneyReminder(journeyId: String) -> Observable<NotificationModel> {
        return apiClient.requestWithDateDecoding(NotificationEndpoint.createJourneyReminder(journeyId: journeyId))
            .map { (response: APIResponse<NotificationResponse>) -> NotificationModel in
                guard let notification = response.data?.notification else {
                    throw NetworkError.invalidResponse
                }
                print("여행 리마인더 알림 생성 응답: \(response.message)")
                return notification
            }
    }
    
    // 테스트용 날씨 알림 생성
    func createWeatherAlert(journeyId: String) -> Observable<NotificationModel> {
        return apiClient.requestWithDateDecoding(NotificationEndpoint.createWeatherAlert(journeyId: journeyId))
            .map { (response: APIResponse<NotificationResponse>) -> NotificationModel in
                guard let notification = response.data?.notification else {
                    throw NetworkError.invalidResponse
                }
                print("날씨 알림 생성 응답: \(response.message)")
                return notification
            }
    }
}

// 응답 모델
struct UnreadCountResponse: Codable {
    let count: Int
}

struct NotificationResponse: Codable {
    let notification: NotificationModel
}
