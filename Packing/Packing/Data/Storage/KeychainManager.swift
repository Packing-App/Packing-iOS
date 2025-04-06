//
//  KeychainManager.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import KeychainAccess

class KeyChainTokenStorage {
    static let shared = KeyChainTokenStorage()
    
    private init() {}
    
    private let keychain: Keychain = Keychain(service: "me.iyungui.Packing")
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let userIdKey = "userId"
    
    
    var accessToken: String? {
        get {
            try? keychain.getString(accessTokenKey)
        }
        set {
            guard let newValue = newValue else {
                try? keychain.remove(accessTokenKey)
                return
            }
            try? keychain.set(newValue, key: accessTokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            try? keychain.getString(refreshTokenKey)
        }
        set {
            guard let newValue = newValue else {
                try? keychain.remove(refreshTokenKey)
                return
            }
            try? keychain.set(newValue, key: refreshTokenKey)
        }
    }
    
    var userId: String? {
        get {
            try? keychain.getString(userIdKey)
        }
        set {
            guard let newValue = newValue else {
                try? keychain.remove(userIdKey)
                return
            }
            try? keychain.set(newValue, key: userIdKey)
        }
    }
    
    var isLoggedIn: Bool {
        return accessToken != nil && refreshToken != nil
    }
    
    func saveTokens(accessToken: String, refreshToken: String, userId: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userId = userId
    }
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        userId = nil
    }
}
