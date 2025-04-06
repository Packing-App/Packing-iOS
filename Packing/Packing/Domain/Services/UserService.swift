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
    private let apiClient: APIClient
    private let tokenManager: KeyChainTokenStorage
    private let userManager: UserManager
    
    init(apiClient: APIClient = .shared,
         tokenManager: KeyChainTokenStorage = .shared,
         userManager: UserManager = .shared) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
        self.userManager = userManager
    }
    
    func getMyProfile() -> Observable<User> {
        return apiClient.request(APIEndpoint.getMyProfile)
            .map { (response: APIResponse<TokenData>) -> User in
                guard let data = response.data else {
                    throw NetworkError.invalidResponse
                }
                
                // 사용자 정보 저장
                self.userManager.setCurrentUser(data.user)
                
                return data.user
            }
            .catch { error in
                throw error
            }
    }
    
    func updateProfile(name: String, intro: String) -> Observable<User> {
        return apiClient.request(APIEndpoint.updateProfile(name: name, intro: intro))
            .map { (response: APIResponse<TokenData>) -> User in
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
            .map { tokenData -> String in
                // 업데이트된 프로필 이미지 URL 반환
                guard let profileImage = tokenData.user.profileImage else {
                    throw NetworkError.invalidResponse
                }
                
                // 사용자 정보 갱신
                self.userManager.setCurrentUser(tokenData.user)
                
                return profileImage
            }
            .catch { error in
                throw error
            }
    }
}
