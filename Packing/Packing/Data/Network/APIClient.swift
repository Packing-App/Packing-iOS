//
//  APIClient.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import RxSwift

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: any Endpoints) -> Observable<T>
    func requestWithDateDecoding<T: Decodable>(_ endpoint: any Endpoints) -> Observable<T>
    func uploadImage(imageData: Data, endpoint: any Endpoints) -> Observable<ProfileImageResponse>
}

class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private let session: URLSession
    private let tokenManager: KeyChainTokenStorage
    private let disposeBag = DisposeBag()
    
    private init(
        session: URLSession = .shared,
        tokenManager: KeyChainTokenStorage = .shared
    ) {
        self.session = session
        self.tokenManager = tokenManager
    }
    
    func request<T: Decodable>(_ endpoint: any Endpoints) -> Observable<T> {
        return Observable.create { [weak self] observer in
            guard let self = self, let url = endpoint.url() else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let languageCode = Locale.current.language.languageCode?.identifier ?? "ko"
            request.addValue(languageCode, forHTTPHeaderField: "Accept-Language")

            // 인증이 필요한 endpoints에는 token 추가
            if self.requiresAuthentication(endpoint) {
                if let token = self.tokenManager.accessToken {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    observer.onError(NetworkError.unauthorized(nil))
                    return Disposables.create()
                }
            }
            
            // HTTP body 설정 (GET 요청에는 body를 설정하지 않음)
            if endpoint.method != .get, let params = endpoint.parameters {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                } catch {
                    observer.onError(NetworkError.requestFailed(error))
                    return Disposables.create()
                }
            }
            
            // 네트워크 요청 실행
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(NetworkError.requestFailed(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(NetworkError.invalidResponse)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    guard let data = data else {
                        observer.onError(NetworkError.invalidResponse)
                        return
                    }
                    
                    do {
                        let decodedObject = try JSONDecoder().decode(T.self, from: data)
                        observer.onNext(decodedObject)
                        observer.onCompleted()
                    } catch let error {
                        print("디코딩 오류: \(error)")
                        
                        // 디코딩 오류 세부 정보 출력
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("키 없음: \(key.stringValue), 경로: \(context.codingPath)")
                            case .typeMismatch(let type, let context):
                                print("타입 불일치: \(type), 경로: \(context.codingPath)")
                            case .valueNotFound(let type, let context):
                                print("값 없음: \(type), 경로: \(context.codingPath)")
                            case .dataCorrupted(let context):
                                print("데이터 손상: \(context)")
                            @unknown default:
                                print("알 수 없는 디코딩 오류")
                            }
                        }
                        
                        observer.onError(NetworkError.decodingFailed(error))
                    }
                case 401:
                    // endpoint 가 refreshToken 인데, 401 에러다! -> networkerror 뱉고 로그아웃 해야함.
                    if case .refreshToken = endpoint as! AuthEndpoint {
                        print("로그아웃 해야해")
                        AuthCoordinator.shared.navigateToLogin()
                        observer.onError(NetworkError.unauthorized(nil))
                        return
                    }
                    
                    print("refreshToken 호출 전")
                    self.refreshToken()
                        .flatMap { _ -> Observable<T> in
                            // 토큰 갱신 성공 시 원래 요청 재시도
                            print("원래 요청 재시도!")
                            return self.request(endpoint)
                        }
                        .subscribe(
                            onNext: { result in
                                observer.onNext(result)
                                observer.onCompleted()
                            },
                            onError: { error in
                                print("refreshToken 호출 오류")
                                AuthCoordinator.shared.navigateToLogin()
                                observer.onError(error)
                            }
                        )
                        .disposed(by: self.disposeBag)
                    
                case 404:
                    observer.onError(NetworkError.notFound)
                    
                default:    // server error
                    if let data = data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            observer.onError(NetworkError.serverError(errorResponse.message))
                        } catch {
                            observer.onError(NetworkError.serverError("Server error: \(httpResponse.statusCode)"))
                        }
                    } else {
                        observer.onError(NetworkError.serverError("Server error: \(httpResponse.statusCode)"))
                    }
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func requestWithDateDecoding<T: Decodable>(_ endpoint: any Endpoints) -> Observable<T> {
        return Observable.create { [weak self] observer in
            guard let self = self, let url = endpoint.url() else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                               
            let languageCode = Locale.current.language.languageCode?.identifier ?? "ko"
            request.addValue(languageCode, forHTTPHeaderField: "Accept-Language")
            
            
            if self.requiresAuthentication(endpoint) {
                if let token = self.tokenManager.accessToken {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    observer.onError(NetworkError.unauthorized(nil))
                    return Disposables.create()
                }
            }
            
            if let params = endpoint.parameters {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                } catch {
                    observer.onError(NetworkError.requestFailed(error))
                    return Disposables.create()
                }
            }
            
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(NetworkError.requestFailed(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(NetworkError.invalidResponse)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    guard let data = data else {
                        observer.onError(NetworkError.invalidResponse)
                        return
                    }
                    
                    do {
                        // 날짜 디코딩 전략이 설정된 디코더 사용
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .custom { decoder in
                            let container = try decoder.singleValueContainer()
                            let dateString = try container.decode(String.self)
                            let formatter = ISO8601DateFormatter()
                            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                            
                            if let date = formatter.date(from: dateString) {
                                return date
                            }
                            
                            throw DecodingError.dataCorruptedError(
                                in: container,
                                debugDescription: "날짜 형식을 파싱할 수 없습니다: \(dateString)"
                            )
                        }
                        
                        let decodedObject = try decoder.decode(T.self, from: data)
                        observer.onNext(decodedObject)
                        observer.onCompleted()
                    } catch let error {
                        print("디코딩 오류: \(error)")
                        
                        // 디코딩 오류 세부 정보 출력
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("키 없음: \(key.stringValue), 경로: \(context.codingPath)")
                            case .typeMismatch(let type, let context):
                                print("타입 불일치: \(type), 경로: \(context.codingPath)")
                            case .valueNotFound(let type, let context):
                                print("값 없음: \(type), 경로: \(context.codingPath)")
                            case .dataCorrupted(let context):
                                print("데이터 손상: \(context)")
                            @unknown default:
                                print("알 수 없는 디코딩 오류")
                            }
                        }
                        
                        observer.onError(NetworkError.decodingFailed(error))
                    }
                
                    
                case 401:
                    // endpoint 가 refreshToken 인데, 401 에러다! -> networkerror 뱉고 로그아웃 해야함.
                    if case .refreshToken = endpoint as! AuthEndpoint {
                        print("로그아웃 해야해")
                        AuthCoordinator.shared.navigateToLogin()
                        observer.onError(NetworkError.unauthorized(nil))
                        return
                    }
                    
                    print("refreshToken 호출 전")
                    self.refreshToken()
                        .flatMap { _ -> Observable<T> in
                            // 토큰 갱신 성공 시 원래 요청 재시도
                            print("원래 요청 재시도!")
                            return self.requestWithDateDecoding(endpoint)
                        }
                        .subscribe(
                            onNext: { result in
                                observer.onNext(result)
                                observer.onCompleted()
                            },
                            onError: { error in
                                print("refreshToken 호출 오류")
                                AuthCoordinator.shared.navigateToLogin()
                                observer.onError(error)
                            }
                        )
                        .disposed(by: self.disposeBag)
                case 404:
                    observer.onError(NetworkError.notFound)
                    
                default:
                    if let data = data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            observer.onError(NetworkError.serverError(errorResponse.message))
                        } catch {
                            observer.onError(NetworkError.serverError("Server error: \(httpResponse.statusCode)"))
                        }
                    } else {
                        observer.onError(NetworkError.serverError("Server error: \(httpResponse.statusCode)"))
                    }
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }

    private func requiresAuthentication(_ endpoint: any Endpoints) -> Bool {
        // AuthEndpoint의 인증이 필요없는 케이스들
        if let authEndpoint = endpoint as? AuthEndpoint {
            switch authEndpoint {
            case .register, .login, .verifyEmail, .resendVerificationCode,
                 .forgotPassword, .verifyResetCode, .resetPassword, .refreshToken,
                 .googleLogin, .kakaoLogin, .naverLogin, .appleVerify:
                return false
            default:
                return true
            }
        }
        
        // LocationEndpoint는 인증이 필요없음
        if endpoint is LocationEndpoint {
            return false
        }
        
        // 나머지 모든 endpoint는 인증 필요
        return true
    }

    private func refreshToken() -> Observable<String> {
        print(#fileID, #function, #line, "- ")
        guard let refreshToken = tokenManager.refreshToken else {
            print("refreshToken is nil or unavailable")
            tokenManager.clearTokens()
            AuthCoordinator.shared.navigateToLogin()
            return Observable.error(NetworkError.unauthorized(nil))
        }
        
        let refreshEndpoint = AuthEndpoint.refreshToken(refreshToken: refreshToken)
        
        return self.request(refreshEndpoint)
            .map { (response: APIResponse<RefreshTokenResponse>) -> String in
                guard let tokenData = response.data else {
                    print("tokenData is invalid")
                    throw NetworkError.invalidResponse
                }
                self.tokenManager.accessToken = tokenData.accessToken
                
                return tokenData.accessToken
            }
            .catch { error in
                print("refreshToken error: \(error.localizedDescription)")
                self.tokenManager.clearTokens()
                AuthCoordinator.shared.navigateToLogin()
                return Observable.error(NetworkError.unauthorized(nil))
            }
    }
    
    // 멀티파트 폼 데이터 요청 (이미지 업로드용)
    func uploadImage(imageData: Data, endpoint: any Endpoints) -> Observable<ProfileImageResponse> {
        return Observable.create { [weak self] observer in
            guard let self = self, let url = endpoint.url() else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            // 멀티파트 폼 데이터 경계 생성
            let boundary = UUID().uuidString
            
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            // 인증 토큰 추가
            if let token = self.tokenManager.accessToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                observer.onError(NetworkError.unauthorized(nil))
                return Disposables.create()
            }
            
            // 이미지 데이터 생성
            var body = Data()
            
            // 경계 시작
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"profileImage\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
            
            // 경계 종료
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            
            request.httpBody = body
            
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(NetworkError.requestFailed(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(NetworkError.invalidResponse)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    guard let data = data else {
                        observer.onError(NetworkError.invalidResponse)
                        return
                    }
                    
                    do {
                        let decodedObject = try JSONDecoder().decode(APIResponse<ProfileImageResponse>.self, from: data)
                        if let profileImageData = decodedObject.data {
                            observer.onNext(profileImageData)
                            observer.onCompleted()
                        } else {
                            observer.onError(NetworkError.invalidResponse)
                        }
                    } catch {
                        observer.onError(NetworkError.decodingFailed(error))
                    }
                    
                case 401:
                    
                    self.refreshToken()
                        .flatMap { _ -> Observable<ProfileImageResponse> in
                            // 토큰 갱신 성공 시 원래 요청 재시도
                            return self.uploadImage(imageData: imageData, endpoint: endpoint)
                        }
                        .subscribe(
                            onNext: { result in
                                observer.onNext(result)
                                observer.onCompleted()
                            },
                            onError: { error in
                                AuthCoordinator.shared.navigateToLogin()
                                observer.onError(error)
                            }
                        )
                        .disposed(by: self.disposeBag)
                default:
                    if let data = data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            observer.onError(NetworkError.serverError(errorResponse.message))
                        } catch {
                            observer.onError(NetworkError.serverError("서버 오류: \(httpResponse.statusCode)"))
                        }
                    } else {
                        observer.onError(NetworkError.serverError("서버 오류: \(httpResponse.statusCode)"))
                    }
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

// MARK: - APIClient Extension for Async/Await support

extension APIClientProtocol {
    func requestAsync<T: Decodable>(_ endpoint: any Endpoints) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            var disposable: Disposable?
            
            disposable = request(endpoint)
                .subscribe(
                    onNext: { (response: T) in
                        continuation.resume(returning: response)
                        // 안전하게 disposable 해제
                        disposable?.dispose()
                    },
                    onError: { error in
                        continuation.resume(throwing: error)
                        // 안전하게 disposable 해제
                        disposable?.dispose()
                    }
                )
        }
    }
    
    func requestWithDateDecodingAsync<T: Decodable>(_ endpoint: any Endpoints) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            var disposable: Disposable?
            
            disposable = requestWithDateDecoding(endpoint)
                .subscribe(
                    onNext: { (response: T) in
                        continuation.resume(returning: response)
                        // 안전하게 disposable 해제
                        disposable?.dispose()
                    },
                    onError: { error in
                        continuation.resume(throwing: error)
                        // 안전하게 disposable 해제
                        disposable?.dispose()
                    }
                )
        }
    }
}
