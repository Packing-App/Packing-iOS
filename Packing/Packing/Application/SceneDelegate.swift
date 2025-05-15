//
//  SceneDelegate.swift
//  Packing
//
//  Created by 이융의 on 3/24/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var authCoordinator: AuthCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Thread.sleep(forTimeInterval: 1.0) // 스플래시 화면 표시 시간
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowScene = windowScene
        
        // AuthCoordinator 초기화 및 설정
        let coordinator = AuthCoordinator.shared
        coordinator.configure(with: window!)
        self.authCoordinator = coordinator
        
        // Coordinator를 통해 앱 시작 흐름 관리
        coordinator.start()
        
        if let notificationResponse = connectionOptions.notificationResponse {
            handleNotificationResponse(notificationResponse)
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let type = userInfo["type"] as? String else { return }
        
        switch type {
        case "invitation":
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.authCoordinator?.navigateToNotifications()
            }
        case "weather", "reminder":
            if let journeyId = userInfo["journeyId"] as? Journey {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.authCoordinator?.navigateToJourneyDetail(journey: journeyId)
                }
            }
        default:
            break
        }
    }
    
    // 인증 실패 처리
    private func handleAuthenticationFailure() {
        // 로그인 화면으로 이동 (이미 AuthCoordinator에서 처리되었을 수 있음)
        authCoordinator?.navigateToLogin()
        
        // 추가적인 정리 작업 수행
        clearUserData()
        
        // 필요한 경우 사용자에게 알림 표시
        showAuthFailureAlert()
    }
    
    // 사용자 데이터 정리
    private func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "lastLoginDate")
//        UserDefaults.standard.removeObject(forKey: "tempDeviceToken")
    }
    
    // 인증 실패 알림 표시
    private func showAuthFailureAlert() {
        DispatchQueue.main.async {
            // 현재 화면에 경고창 표시
            guard let rootViewController = self.window?.rootViewController else { return }
            
            let alert = UIAlertController(
                title: "세션 만료".localized,
                message: "로그인 세션이 만료되었습니다. 다시 로그인해주세요.".localized,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            
            // 최상위 뷰 컨트롤러 찾기
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            
            topViewController.present(alert, animated: true)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // 앱이 백그라운드로 전환될 때 호출됨
        // 리소스 정리 등의 작업
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 앱이 활성화될 때 호출됨
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // 앱이 비활성화될 때 호출됨
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 앱이 포그라운드로 전환될 때 호출됨
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // 앱이 백그라운드로 전환될 때 호출됨
    }
    
    deinit {
        // 알림 구독 해제
        NotificationCenter.default.removeObserver(self)
    }
}
