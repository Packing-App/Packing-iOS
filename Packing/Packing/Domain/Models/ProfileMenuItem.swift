//
//  ProfileMenuItem.swift
//  Packing
//
//  Created by 이융의 on 4/19/25.
//

import Foundation

enum ProfileMenuItem: String, CaseIterable {
    case connectedAccount = "연결된 계정" // (just display)
    case versionInfo = "버전 정보"  // (just display)
    case developerInfo = "개발자 정보"   // navigate to another View
    case privacy = "개인정보처리방침"  // navigate to another View
    case legal = "서비스 이용약관"  // navigate to another View
    case logout = "로그아웃"    // button (show alert)
    case deleteId = "회원탈퇴"  // button (show alert)
    
    var isDestructive: Bool {
        return self == .logout || self == .deleteId
    }
    
    var isNavigatable: Bool {
        return self == .developerInfo || self == .privacy || self == .legal
    }
    
    var isDisplayOnly: Bool {
        return self == .connectedAccount || self == .versionInfo
    }
}
