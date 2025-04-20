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
                       theme: TravelTheme,
                       isPrivate: Bool) -> Observable<Journey>

    // 여행 정보 업데이트
    func updateJourney(id: String,
                      title: String?,
                      transportType: TransportType?,
                      origin: String?,
                      destination: String?,
                      startDate: Date?,
                      endDate: Date?,
                      theme: TravelTheme?,
                      isPrivate: Bool?) -> Observable<Journey>
    
    // 여행 삭제
    func deleteJourney(id: String) -> Observable<Void>
    
    // 여행에 참가자 초대
    func inviteParticipant(journeyId: String, email: String) -> Observable<NotificationResponse>
    
    // 여행 참가자 제거
    func removeParticipant(journeyId: String, userId: String) -> Observable<Void>
    
    // 여행 초대 응답 (수락/거절)
    func respondToInvitation(notificationId: String, accept: Bool) -> Observable<Void>
    
    // 여행 추천 준비물 조회
    func getRecommendations(journeyId: String) -> Observable<RecommendationResponse>
}
