//
//  JourneyService.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import RxSwift

protocol JourneyServiceProtocol {
    func getJourneys() -> Observable<[Journey]>
    func getJourneyById(id: String) -> Observable<Journey>
    
    func createJourney(title: String,
                       transportType: TransportType,
                       origin: String,
                       destination: String,
                       startDate: Date,
                       endDate: Date,
                       themes: [TravelTheme],
                       isPrivate: Bool) -> Observable<Journey>

    // 여행 정보 업데이트
    func updateJourney(id: String,
                      title: String?,
                      transportType: TransportType?,
                      origin: String?,
                      destination: String?,
                      startDate: Date?,
                      endDate: Date?,
                      themes: [TravelTheme]?,
                      isPrivate: Bool?) -> Observable<Journey>
    
    // 여행 삭제
    func deleteJourney(id: String) async throws -> Bool
    
    // 여행에 참가자 초대
    func inviteParticipant(journeyId: String, email: String) -> Observable<NotificationResponse>
    
    // 여행 참가자 제거
    func removeParticipant(journeyId: String, userId: String) -> Observable<Bool>
    
    // 여행 초대 응답 (수락/거절)
    func respondToInvitation(notificationId: String, accept: Bool) -> Observable<Bool>
    
    // 여행 추천 준비물 조회
    func getRecommendations(journeyId: String) -> Observable<RecommendationResponse>
}

class JourneyService: JourneyServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    // MARK: - 여행 목록 조회
    func getJourneys() -> Observable<[Journey]> {
        return apiClient.requestWithDateDecoding(JourneyEndpoint.getJourneys)
            .map { (response: APIResponse<[Journey]>) -> [Journey] in
                guard let journeys = response.data else {
                    throw NetworkError.invalidResponse
                }
                return journeys
            }
            .catch { error in
                return Observable.error(error)
            }
    }
    
    // MARK: - 특정 여행 조회
    func getJourneyById(id: String) -> Observable<Journey> {
        return apiClient.request(JourneyEndpoint.getJourneyById(id: id))
            .map { (response: APIResponse<Journey>) -> Journey in
                guard let journey = response.data else {
                    throw NetworkError.invalidResponse
                }
                return journey
            }
            .catch { error in
                return Observable.error(error)
            }
    }

    // MARK: - 새로운 여행 생성
    func createJourney(title: String,
                      transportType: TransportType,
                      origin: String,
                      destination: String,
                      startDate: Date,
                      endDate: Date,
                      themes: [TravelTheme],
                      isPrivate: Bool) -> Observable<Journey> {
                
        return apiClient.requestWithDateDecoding(JourneyEndpoint.createJourney(
            title: title,
            transportType: transportType,
            origin: origin,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            themes: themes,
            isPrivate: isPrivate
        ))
        .map { (response: APIResponse<Journey>) -> Journey in
            guard let journey = response.data else {
                throw NetworkError.invalidResponse
            }
            return journey
        }
        .catch { error in
            return Observable.error(error)
        }
    }
    
    // MARK: - 여행 정보 업데이트
    func updateJourney(id: String,
                      title: String?,
                      transportType: TransportType?,
                      origin: String?,
                      destination: String?,
                      startDate: Date?,
                      endDate: Date?,
                      themes: [TravelTheme]?,
                      isPrivate: Bool?) -> Observable<Journey> {
        
        return apiClient.requestWithDateDecoding(JourneyEndpoint.updateJourney(
            id: id,
            title: title,
            transportType: transportType,
            origin: origin,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            themes: themes,
            isPrivate: isPrivate
        ))
        .map { (response: APIResponse<Journey>) -> Journey in
            guard let journey = response.data else {
                throw NetworkError.invalidResponse
            }
            return journey
        }
        .catch { error in
            return Observable.error(error)
        }
    }
    
    // MARK: - 여행 삭제
    func deleteJourney(id: String) async throws -> Bool {
        let response: APIResponse<Bool> = try await apiClient.requestAsync(JourneyEndpoint.deleteJourney(id: id))
        guard response.success else {
            throw NetworkError.serverError(response.message)
        }
        return response.success
    }
    
    // MARK: - 여행에 참가자 초대
    func inviteParticipant(journeyId: String, email: String) -> Observable<NotificationResponse> {
        return apiClient.requestWithDateDecoding(JourneyEndpoint.inviteParticipant(journeyId: journeyId, email: email))
            .map { (response: APIResponse<NotificationResponse>) -> NotificationResponse in
                guard let notificationResponse = response.data else {
                    throw NetworkError.invalidResponse
                }
                return notificationResponse
            }
            .catch { error in
                return Observable.error(error)
            }
    }
    
    // MARK: - 여행 참가자 제거
    func removeParticipant(journeyId: String, userId: String) -> Observable<Bool> {
        return apiClient.request(JourneyEndpoint.removeParticipant(journeyId: journeyId, userId: userId))
            .map { (response: APIResponse<Bool>) -> Bool in
                return response.success
            }
            .catch { error in
                return Observable.error(error)
            }
    }
    
    // MARK: - 여행 초대 응답 (수락/거절)
    func respondToInvitation(notificationId: String, accept: Bool) -> Observable<Bool> {
        print(#fileID, #function, #line, "- ")
        return apiClient.request(JourneyEndpoint.respondToInvitation(notificationId: notificationId, accept: accept))
            .map { (response: APIResponse<Bool>) -> Bool in
                return response.success
            }
            .catch { error in
                return Observable.error(error)
            }
    }
    
    // MARK: - 여행 추천 준비물 조회
    func getRecommendations(journeyId: String) -> Observable<RecommendationResponse> {
        print(#fileID, #function, #line, "- ")
        return apiClient.requestWithDateDecoding(JourneyEndpoint.getRecommendations(journeyId: journeyId))
            .map { (response: APIResponse<RecommendationResponse>) -> RecommendationResponse in
                guard let recommendations = response.data else {
                    throw NetworkError.invalidResponse
                }
                return recommendations
            }
            .catch { error in
                return Observable.error(error)
            }
    }
}
