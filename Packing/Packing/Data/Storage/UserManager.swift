//
//  UserManager.swift
//  Packing
//
//  Created by 이융의 on 4/6/25.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private let userDefaultsKey = "currentUser"
    private let userDefaults = UserDefaults.standard
    
    private(set) var currentUser: User? {
        didSet {
            saveUserToDefaults()
        }
    }
    
    private init() {
        loadUserFromDefaults()
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
    
    private func loadUserFromDefaults() {
        guard let userData = userDefaults.data(forKey: userDefaultsKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            currentUser = try decoder.decode(User.self, from: userData)
        } catch {
            print("Error loading user from UserDefaults: \(error)")
        }
    }
}
