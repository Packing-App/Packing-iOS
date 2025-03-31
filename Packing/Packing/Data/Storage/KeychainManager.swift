//
//  KeychainManager.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import KeychainAccess

protocol TokenStorage {
    func saveTokens(accessToken: String, refreshToken: String, userId: String)
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
    func getUserId() -> String?
    func clearTokens()
}

class KeyChainTokenStorage: TokenStorage {
    private let keychain: Keychain = Keychain(service: "me.iyungui.Packing")
    
    func saveTokens(accessToken: String, refreshToken: String, userId: String) {
        try? keychain.set(accessToken, key: "accessToken")
        try? keychain.set(refreshToken, key: "refreshToken")
        try? keychain.set(userId, key: "userId")
    }
    
    func getAccessToken() -> String? {
        return try? keychain.get("accessToken")
    }
    
    func getRefreshToken() -> String? {
        return try? keychain.get("refreshToken")
    }
    
    func getUserId() -> String? {
        return try? keychain.get("userId")
    }
    
    func clearTokens() {
        try? keychain.remove("accessToken")
        try? keychain.remove("refreshToken")
        try? keychain.remove("userId")
    }
}
