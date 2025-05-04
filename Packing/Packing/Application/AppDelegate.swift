//
//  AppDelegate.swift
//  Packing
//
//  Created by 이융의 on 3/24/25.
//

import UIKit
import UserNotifications
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var disposeBag = DisposeBag()

    private let deviceService: DeviceServiceProtocol = DeviceService()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 푸시 알림 설정
        setupPushNotifications(application: application)
        
        return true
    }
    
    // MARK: - 푸시 알림 설정
    private func setupPushNotifications(application: UIApplication) {
        // 알림 센터 대리자 설정
        UNUserNotificationCenter.current().delegate = self
        
        // 알림 권한 요청
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("푸시 알림 권한이 허용되었습니다.")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("푸시 알림 권한 요청 오류: \(error.localizedDescription)")
            } else {
                print("푸시 알림 권한이 거부되었습니다.")
            }
        }
    }
    
    // 디바이스 토큰 수신
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("디바이스 토큰: \(tokenString)")
        
        // 서버에 토큰 등록 (사용자가 로그인 상태인 경우만)
        if UserManager.shared.currentUser != nil {
            deviceService.updateDeviceToken(token: tokenString)
                .subscribe(onNext: { success in
                    print("디바이스 토큰 등록 성공: \(success)")
                }, onError: { error in
                    print("디바이스 토큰 등록 실패: \(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        } else {
            print("로그인 전")
            UserDefaults.standard.set(tokenString, forKey: "tempDeviceToken")
        }
    }
    
    // 디바이스 토큰 등록 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("푸시 알림 등록 실패: \(error.localizedDescription)")
    }
    
    // MARK: - 푸시 알림 수신 및 처리 (앱이 포그라운드 상태일 때)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        handleNotification(userInfo)
        
        // iOS 14 이상에서는 .banner, iOS 14 미만에서는 .alert 사용
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // MARK: - 푸시 알림 탭 처리 (앱이 백그라운드 또는 종료 상태일 때)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo, tapped: true)
        completionHandler()
    }
    
    // MARK: - 알림 데이터 처리
    private func handleNotification(_ userInfo: [AnyHashable: Any], tapped: Bool = false) {
        guard let type = userInfo["type"] as? String else { return }
        
        // NotificationCenter를 통해 알림 데이터 전달
        switch type {
        case "invitation":
            if let notificationId = userInfo["notificationId"] as? String,
               let journeyId = userInfo["journeyId"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("DidReceiveInvitationNotification"),
                    object: nil,
                    userInfo: [
                        "notificationId": notificationId,
                        "journeyId": journeyId,
                        "tapped": tapped
                    ]
                )
            }
        case "weather":
            if let journeyId = userInfo["journeyId"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("DidReceiveWeatherNotification"),
                    object: nil,
                    userInfo: [
                        "journeyId": journeyId,
                        "tapped": tapped
                    ]
                )
            }
        case "reminder":
            if let journeyId = userInfo["journeyId"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("DidReceiveReminderNotification"),
                    object: nil,
                    userInfo: [
                        "journeyId": journeyId,
                        "tapped": tapped
                    ]
                )
            }
        default:
            break
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 필요한 정리 작업
    }
}
