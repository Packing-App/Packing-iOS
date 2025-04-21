//
//  UserManager.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    private let tokenStorage: KeyChainTokenStorage

    // 로그인 상태 변경 알림
    static let loginStatusChangedNotification = Notification.Name("loginStatusChanged")
    
    private init(tokenStorage: KeyChainTokenStorage = .shared) {
        self.tokenStorage = tokenStorage
        self.loadUser()
    }

    private let userDefaultsKey = "currentUser"
    private let userDefaults = UserDefaults.standard
    
    private(set) var currentUser: User? {
        didSet {
            saveUserToDefaults()
        }
    }
    
    func setCurrentUser(_ user: User?) {
        currentUser = user
    }
    
    func clearCurrentUser() {
        print(#fileID, #function, #line, "- ")
        currentUser = nil
    }
    
    private func saveUserToDefaults() {
        guard let user = currentUser else {
            userDefaults.removeObject(forKey: userDefaultsKey)
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            userDefaults.set(userData, forKey: userDefaultsKey)
        } catch {
            print("Error saving user to UserDefaults: \(error)")
        }
    }
    
    func logout() {
        tokenStorage.clearTokens()
        // 유저 정보 클리어
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
        
        // 로그인 상태 변경 알림
        NotificationCenter.default.post(name: UserManager.loginStatusChangedNotification, object: nil)
    }
    
    // 토큰 갱신 처리
    func updateTokens(accessToken: String, refreshToken: String) {
        tokenStorage.accessToken = accessToken
        tokenStorage.refreshToken = refreshToken
    }
    
    // 유저 프로필 업데이트
    func updateUserProfile(user: User) {
        self.currentUser = user
        
        // UserDefaults에 유저 정보 캐싱 업데이트
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    private func loadUser() {
        // 토큰이 있으면 유저가 로그인된 상태로 간주
        if tokenStorage.accessToken != nil {
            // 실제 앱에서는 토큰과 함께 저장된 유저 정보를 로드하거나
            // 서버에서 프로필 정보를 가져올 수 있음
            if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
               let user = try? JSONDecoder().decode(User.self, from: userData) {
                self.currentUser = user
            }
        } else {
            self.currentUser = nil
            
        }
    }
}
