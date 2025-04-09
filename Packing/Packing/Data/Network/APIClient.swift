//
//  APIClient.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import Foundation
import RxSwift

// MARK: - API 모델

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: T?
}

struct UserResponse: Codable {
    let user: User
}

struct TokenData: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
}

class APIClient {
    static let shared = APIClient()
    private let session: URLSession
    private let tokenManager: KeyChainTokenStorage
    
    private init(
        session: URLSession = .shared,
        tokenManager: KeyChainTokenStorage = .shared
    ) {
        self.session = session
        self.tokenManager = tokenManager
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> Observable<T> {
        return Observable.create { [weak self] observer in
            guard let self = self, let url = endpoint.url() else {
                observer.onError(NetworkError.invalidURL)
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            // 인증이 필요한 endpoints에는 token 추가
            if self.requiresAuthentication(endpoint) {
                if let token = self.tokenManager.accessToken {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    observer.onError(NetworkError.unauthorized(nil))
                    return Disposables.create()
                }
            }
            
            // HTTP body 설정
            if let params = endpoint.parameters {
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
                        observer.onError(NetworkError.decodingFailed(error))
                    }
                case 401:
                    if let data = data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            observer.onError(NetworkError.unauthorized(errorResponse.message))
                        } catch {
                            observer.onError(NetworkError.unauthorized(nil))
                        }
                    } else {
                        observer.onError(NetworkError.unauthorized(nil))
                    }
                    
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

    private func requiresAuthentication(_ endpoint: APIEndpoint) -> Bool {
        switch endpoint {
        case .register, .login, .verifyEmail, .resendVerificationCode,
             .forgotPassword, .verifyResetCode, .resetPassword, .refreshToken,
             .googleLogin, .kakaoLogin, .naverLogin, .appleVerify:
            return false
        default:
            return true
        }
    }
    
    // MARK: - 토큰 갱신 및 재시도 로직
    
    private func refreshTokenAndRetry<T: Decodable>(
        endpoint: APIEndpoint,
        observer: AnyObserver<T>
    ) {
        guard let refreshToken = tokenManager.refreshToken else {
            observer.onError(NetworkError.unauthorized(nil))
            return
        }
        
        let refreshEndpoint = APIEndpoint.refreshToken(refreshToken: refreshToken)
        let refreshRequest: Observable<APIResponse<TokenData>> = self.request(refreshEndpoint)
        
        refreshRequest.subscribe(onNext: { [weak self] (authResponse: APIResponse<TokenData>) in
            guard let self = self else { return }
            
            // 새 토큰 저장
            self.tokenManager.accessToken = authResponse.data?.accessToken
            
            // 원래 요청 재시도
            let originalRequest: Observable<T> = self.request(endpoint)
            
            originalRequest.subscribe(onNext: { (result: T) in
                observer.onNext(result)
                observer.onCompleted()
            }, onError: { error in
                observer.onError(error)
            })
            .disposed(by: DisposeBag())
            
        }, onError: { [weak self] error in
            // 토큰 갱신 실패, 로그아웃 필요
            self?.tokenManager.clearTokens()
            observer.onError(NetworkError.unauthorized(nil))
        })
        .disposed(by: DisposeBag())
    }

    
    // 멀티파트 폼 데이터 요청 (이미지 업로드용)
    func uploadImage(imageData: Data, endpoint: APIEndpoint) -> Observable<TokenData> {
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
                        let decodedObject = try JSONDecoder().decode(APIResponse<TokenData>.self, from: data)
                        if let tokenData = decodedObject.data {
                            observer.onNext(tokenData)
                            observer.onCompleted()
                        } else {
                            observer.onError(NetworkError.invalidResponse)
                        }
                    } catch {
                        observer.onError(NetworkError.decodingFailed(error))
                    }
                    
                case 401:
                    if let data = data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            observer.onError(NetworkError.unauthorized(errorResponse.message))
                        } catch {
                            observer.onError(NetworkError.unauthorized(nil))
                        }
                    } else {
                        observer.onError(NetworkError.unauthorized(nil))
                    }
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
