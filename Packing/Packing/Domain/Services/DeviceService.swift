//
//  DeviceService.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import Foundation
import RxSwift

protocol DeviceServiceProtocol {
    // 디바이스 토큰 등록/업데이트
    func updateDeviceToken(token: String) -> Observable<Bool>
    
    // 푸시 알림 설정 변경
    func updatePushSettings(enabled: Bool) -> Observable<Bool>
    
    // 테스트 알림 전송
    func sendTestNotification() -> Observable<Bool>
    
    // 디바이스 토큰 제거
    func removeDeviceToken() -> Observable<Bool>
}

class DeviceService: DeviceServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    // 디바이스 토큰 등록/업데이트
    func updateDeviceToken(token: String) -> Observable<Bool> {
        print(#fileID, #function, #line, "- ")
        return apiClient.request(APIEndpoint.updateDeviceToken(token: token))
            .map { (response: APIResponse<DeviceTokenResponse>) -> Bool in
                print("디바이스 토큰 업데이트 응답: \(response.message)")
                return response.success
            }
            .catch { error in
                print("디바이스 토큰 업데이트 오류: \(error.localizedDescription)")
                return .just(false)
            }
    }
    
    // 푸시 알림 설정 변경
    func updatePushSettings(enabled: Bool) -> Observable<Bool> {
        return apiClient.request(APIEndpoint.updatePushSettings(enabled: enabled))
            .map { (response: APIResponse<PushSettingsResponse>) -> Bool in
                print("푸시 설정 업데이트 응답: \(response.message)")
                return response.success
            }
            .catch { error in
                print("푸시 설정 업데이트 오류: \(error.localizedDescription)")
                return .just(false)
            }
    }
    
    // 테스트 알림 전송
    func sendTestNotification() -> Observable<Bool> {
        return apiClient.request(APIEndpoint.sendTestNotification)
            .map { (response: APIResponse<EmptyResponse>) -> Bool in
                print("테스트 알림 전송 응답: \(response.message)")
                return response.success
            }
            .catch { error in
                print("테스트 알림 전송 오류: \(error.localizedDescription)")
                return .just(false)
            }
    }
    
    // 디바이스 토큰 제거
    func removeDeviceToken() -> Observable<Bool> {
        return apiClient.request(APIEndpoint.removeDeviceToken)
            .map { (response: APIResponse<EmptyResponse>) -> Bool in
                print("디바이스 토큰 제거 응답: \(response.message)")
                return response.success
            }
            .catch { error in
                print("디바이스 토큰 제거 오류: \(error.localizedDescription)")
                return .just(false)
            }
    }
}
