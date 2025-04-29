//
//  FriendShipService.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import Foundation
import RxSwift

protocol FriendshipServiceProtocol {
    func getFriends() -> Observable<[Friend]>
    func getFriendRequests() -> Observable<FriendRequestsResponse>
    func sendFriendRequest(email: String) -> Observable<Friendship>
    func respondToFriendRequest(id: String, accept: Bool) -> Observable<Bool>
    func removeFriend(id: String) -> Observable<Bool>
    func searchFriendByEmail(email: String) -> Observable<[FriendSearchResult]>
}

class FriendshipService: FriendshipServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    // 친구 목록 조회
    func getFriends() -> Observable<[Friend]> {
        return apiClient.request(APIEndpoint.getFriends)
            .map { (response: APIResponse<[Friend]>) -> [Friend] in
                guard let friends = response.data else {
                    return []
                }
                return friends
            }
    }
    
    // 친구 요청 목록 조회
    func getFriendRequests() -> Observable<FriendRequestsResponse> {
        return apiClient.requestWithDateDecoding(APIEndpoint.getFriendRequests)
            .map { (response: APIResponse<FriendRequestsResponse>) -> FriendRequestsResponse in
                guard let requestsData = response.data else {
                    return FriendRequestsResponse(received: [], sent: [])
                }
                return requestsData
            }
    }
    
    // 친구 요청 보내기
    func sendFriendRequest(email: String) -> Observable<Friendship> {
        return apiClient.requestWithDateDecoding(APIEndpoint.sendFriendRequest(email: email))
            .map { (response: APIResponse<Friendship>) -> Friendship in
                guard let friendship = response.data else {
                    throw NetworkError.invalidResponse
                }
                return friendship
            }
    }
    
    // 친구 요청 응답 (수락/거절)
    func respondToFriendRequest(id: String, accept: Bool) -> Observable<Bool> {
        return apiClient.request(APIEndpoint.respondToFriendRequest(id: id, accept: accept))
            .map { (response: APIResponse<Bool>) -> Bool in
                return response.success
            }
    }
    
    // 친구 삭제
    func removeFriend(id: String) -> Observable<Bool> {
        return apiClient.request(APIEndpoint.removeFriend(id: id))
            .map { (response: APIResponse<Bool>) -> Bool in
                return response.success
            }
    }
    
    // 이메일로 친구 검색
    func searchFriendByEmail(email: String) -> Observable<[FriendSearchResult]> {
        return apiClient.request(APIEndpoint.searchFriendByEmail(email: email))
            .map { (response: APIResponse<[FriendSearchResult]>) -> [FriendSearchResult] in
                guard let searchResults = response.data else {
                    return []
                }
                return searchResults
            }
    }
}
