//
//  NetworkError.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(String)
    case unauthorized(String?)
    case notFound
    case networkError
    case unknown
    
    // Equatable 구현
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.notFound, .notFound),
             (.networkError, .networkError),
             (.unknown, .unknown):
            return true
            
        case let (.requestFailed(lhsError), .requestFailed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
            
        case let (.decodingFailed(lhsError), .decodingFailed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
            
        case let (.serverError(lhsMessage), .serverError(rhsMessage)):
            return lhsMessage == rhsMessage
            
        case let (.unauthorized(lhsMessage), .unauthorized(rhsMessage)):
            return lhsMessage == rhsMessage
            
        default:
            return false
        }
    }

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL입니다."
        case .requestFailed(let error):
            return "요청 실패: \(error.localizedDescription)"
        case .invalidResponse:
            return "유효하지 않은 응답입니다."
        case .decodingFailed(let error):
            return "디코딩 실패: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unauthorized(let message):
            return message ?? "권한이 없습니다."
        case .notFound:
            return "리소스를 찾을 수 없습니다."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

