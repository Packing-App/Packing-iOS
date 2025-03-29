//
//  AuthService.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import RxSwift

// login 상태 관찰 가능한 Observable
protocol AuthService {
    func loginWithGoogle() -> Observable<Result<User, Error>>
    func loginWIthKakao() -> Observable<Result<User, Error>>
    func loginWithNaver() -> Observable<Result<User, Error>>
    func loginWithApple(userId: String, email: String?, fullName: PersonNameComponents?) -> Observable<Result<User, Error>>
    func logout() -> Observable<Result<Void, Error>>
}
