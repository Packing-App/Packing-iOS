//
//  NetworkError.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(String)
    case unauthorized
    case notFound
    case networkError
    case unknown
    
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
        case .unauthorized:
            return "인증이 필요합니다."
        case .notFound:
            return "리소스를 찾을 수 없습니다."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
