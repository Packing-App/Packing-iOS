//
//  Journey.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation



enum TransportType {
    case plane
    case train
    case ship
    case bus
    case walk
    case other
}

struct Journey {
    let createrUserId: String   // 여행 생성자 ID
    let title: String   // 여행 제목
    let transportType: TransportType
    let origin: String   // 여행 출발지
    let destination: String   // 여행 도착지
    let startDate: String
    let endDate: String
    let theme: TravelThemeTemplate
    let imageUrl: String
    let isPrivate: Bool
    let participants: [String]  // 여행 참가자 ID 목록
    let createdAt: Date
    let updatedAt: Date
}

extension Journey {
    static let exampleJourneys: [Journey] = [
        Journey(createrUserId: "", title: "플리트비체 5코스 돌기", transportType: .walk, origin: "korea", destination: "플리트비체", startDate: "2023년 12월 1일", endDate: "2023년 12월 7일", theme: , imageUrl: "", isPrivate: false, participants: [], createdAt: Date.now, updatedAt: Date.now),
        Journey(createrUserId: "", title: "다낭", transportType: .walk, origin: "korea", destination: "베트남", startDate: "2023년 12월 1일", endDate: "2023년 12월 7일", theme: , imageUrl: "", isPrivate: false, participants: [], createdAt: Date.now, updatedAt: Date.now)
    ]
}
