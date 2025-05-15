//
//  ProfileMenuItem.swift
//  Packing
//
//  Created by 이융의 on 4/19/25.
//

import Foundation

enum ProfileMenuItem: String, CaseIterable {
    case connectedAccount = "connected_account"
    case versionInfo = "version_info"
    case developerInfo = "developer_info"
    case privacy = "privacy_policy"
    case legal = "terms_of_service"
    case logout = "logout"
    case deleteId = "delete_account"
    
    var isDestructive: Bool {
        return self == .logout || self == .deleteId
    }
    
    var isNavigatable: Bool {
        return self == .developerInfo || self == .privacy || self == .legal
    }
    
    var isDisplayOnly: Bool {
        return self == .connectedAccount || self == .versionInfo
    }
    
    // 새로운 computed property 추가
    var displayName: String {
        switch self {
        case .connectedAccount:
            return "연결된 계정".localized
        case .versionInfo:
            return "버전 정보".localized
        case .developerInfo:
            return "개발자 정보".localized
        case .privacy:
            return "개인정보처리방침".localized
        case .legal:
            return "서비스 이용약관".localized
        case .logout:
            return "로그아웃".localized
        case .deleteId:
            return "회원탈퇴".localized
        }
    }
}
