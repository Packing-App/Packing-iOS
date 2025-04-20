//
//  UserService.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation
import RxSwift
import UIKit

protocol UserServiceProtocol {
    func getMyProfile() -> Observable<User>
    func updateProfile(name: String, intro: String) -> Observable<User>
    func updateProfileImage(image: UIImage) -> Observable<String>
}

class UserService: UserServiceProtocol {
    private let apiClient: APIClientProtocol
    private let tokenManager: KeyChainTokenStorage
    private let userManager: UserManager
    
    init(apiClient: APIClientProtocol = APIClient.shared,
         tokenManager: KeyChainTokenStorage = .shared,
         userManager: UserManager = .shared) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
        self.userManager = userManager
    }
    
    func getMyProfile() -> Observable<User> {
        print("getMyProfile 호출됨")
        
        // 타임아웃 추가로 무한 대기 방지
        return apiClient.request(APIEndpoint.getMyProfile)
            .do(onNext: { _ in print("API 응답 받음") },
                onError: { error in print("API 에러 발생: \(error)") },
                onCompleted: { print("API 호출 완료") })
            .map { (response: APIResponse<UserResponse>) -> User in
                print("응답 매핑 시작")
                guard let data = response.data else {
                    print("응답에 데이터 없음")
                    throw NetworkError.invalidResponse
                }
                
                print("사용자 정보 얻음: \(data.user.name)")
                self.userManager.setCurrentUser(data.user)
                
                return data.user
            }
            .catch { error -> Observable<User> in
                print("getMyProfile 에러 처리: \(error)")
                // 중요: throw error 대신 Observable.error 사용
                return Observable.error(error)
            }
    }
    
    func updateProfile(name: String, intro: String) -> Observable<User> {
        return apiClient.request(APIEndpoint.updateProfile(name: name, intro: intro))
            .map { (response: APIResponse<UserResponse>) -> User in
                guard let data = response.data else {
                    throw NetworkError.invalidResponse
                }
                
                // 사용자 정보 갱신
                self.userManager.setCurrentUser(data.user)
                
                return data.user
            }
            .catch { error in
                throw error
            }
    }
    
    func updateProfileImage(image: UIImage) -> Observable<String> {
        // 이미지를 JPEG 데이터로 변환
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return Observable.error(NetworkError.requestFailed(NSError(domain: "me.packing", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"])))
        }
        
        // 이미지 업로드
        return apiClient.uploadImage(imageData: imageData, endpoint: APIEndpoint.updateProfileImage(imageData: imageData))
            .map { profileImageData -> String in
                return profileImageData.profileImage
            }
            .catch { error in
                throw error
            }
    }
}
