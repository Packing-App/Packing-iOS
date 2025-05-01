//
//  AuthCoordinator.swift
//  Packing
//
//  Created on 4/21/25.
//

import UIKit

// MARK: - Coordinator 프로토콜

/// 기본 Coordinator 프로토콜
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

/// 인증 관련 코디네이터 프로토콜
protocol AuthCoordinatorProtocol: Coordinator {
    func navigateToLogin()
}

// MARK: - AuthCoordinator Implementation

/// 인증 흐름을 관리하는 코디네이터
class AuthCoordinator: AuthCoordinatorProtocol {
    
    // 싱글톤 인스턴스
    static let shared = AuthCoordinator()
    
    // 자식 코디네이터 배열
    var childCoordinators: [Coordinator] = []
    
    // 현재 창 참조
    private weak var window: UIWindow?
    
    // 현재 표시중인 뷰 컨트롤러를 추적
    private weak var currentViewController: UIViewController?
    
    // SceneDelegate에서 초기화할 때 window 설정
    func configure(with window: UIWindow) {
        self.window = window
    }
    
    // 코디네이터 시작
    func start() {
        // 사용자 로그인 상태 확인
        let userManager = UserManager.shared
        
        if userManager.currentUser != nil {
            // 로그인 상태일 경우 메인 화면으로 이동
            showMainScreen()
        } else {
            // 로그인되지 않은 경우 로그인 화면으로 이동
            navigateToLogin()
        }
    }
    
    // 로그인 화면으로 이동
    func navigateToLogin() {
        // 토큰 관련 데이터 정리
        UserManager.shared.logout()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 애니메이션 없이 즉시 변경할지 여부 결정
            let animated = self.window?.rootViewController != nil
            
            // 로그인 화면 생성
            let loginViewController = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginViewController)
            navigationController.isNavigationBarHidden = true
            
            // 화면 전환 애니메이션 추가
            if animated {
                // 애니메이션과 함께 전환
                UIView.transition(with: self.window!,
                                 duration: 0.3,
                                 options: .transitionCrossDissolve,
                                 animations: {
                    self.window?.rootViewController = navigationController
                }, completion: nil)
            } else {
                // 애니메이션 없이 즉시 전환
                self.window?.rootViewController = navigationController
            }
            
            self.currentViewController = loginViewController
        }
    }
    
    // 메인 화면(탭바)으로 이동
    func showMainScreen() {
        guard let window = window else { return }
        
        DispatchQueue.main.async {
            let tabBarController = UITabBarController()
            
            // 홈 탭
            let homeViewController = HomeViewController()
            let homeNavigationController = UINavigationController(rootViewController: homeViewController)
            homeNavigationController.tabBarItem = UITabBarItem(
                title: "내 여행",
                image: UIImage(systemName: "house"),
                selectedImage: UIImage(systemName: "house.fill")
            )
            
            // 친구목록 탭
            let friendsViewController = FriendsViewController()
            let friendsNavigationController = UINavigationController(rootViewController: friendsViewController)
            friendsNavigationController.tabBarItem = UITabBarItem(
                title: "내 친구",
                image: UIImage(systemName: "person.2"),
                selectedImage: UIImage(systemName: "person.2.fill")
            )
            
            // 마이페이지 탭
            let profileReactor = ProfileViewReactor()
            let profileViewController = ProfileViewController(reactor: profileReactor)
            let profileNavigationController = UINavigationController(rootViewController: profileViewController)
            profileNavigationController.tabBarItem = UITabBarItem(
                title: "내 프로필",
                image: UIImage(systemName: "person"),
                selectedImage: UIImage(systemName: "person.fill")
            )
            
            // 탭바에 네비게이션 컨트롤러 추가
            tabBarController.viewControllers = [homeNavigationController, friendsNavigationController, profileNavigationController]
            
            // iOS 15 이상에서 탭바 스타일 설정
            if #available(iOS 15.0, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithDefaultBackground()
                tabBarController.tabBar.standardAppearance = appearance
                tabBarController.tabBar.scrollEdgeAppearance = appearance
            }
            
            // 애니메이션과 함께 루트 뷰 컨트롤러 변경
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                window.rootViewController = tabBarController
            }, completion: nil)
        }
    }
    
    // AuthCoordinator.swift에 추가
    func navigateToNotifications() {
        // 홈 탭으로 이동 (0번 인덱스)
        navigateToTab(0)
        
        // 현재 네비게이션 컨트롤러 가져오기
        guard let navigationController = currentNavigationController() else { return }
        
        // 이미 NotificationsViewController가 스택에 있는지 확인
        if navigationController.viewControllers.contains(where: { $0 is NotificationsViewController }) {
            // 있으면 해당 뷰 컨트롤러까지 팝
            navigationController.popToViewController(
                navigationController.viewControllers.first(where: { $0 is NotificationsViewController })!,
                animated: true
            )
        } else {
            // 없으면 새로 푸시
            let journeyService: JourneyServiceProtocol = JourneyService()
            let reactor: NotificationsReactor = NotificationsReactor(notificationService: NotificationService(), journeyService: journeyService)
            let notificationsViewController = NotificationsViewController(reactor: reactor)
            navigationController.pushViewController(notificationsViewController, animated: true)
        }
    }

    func navigateToJourneyDetail(journey: Journey) {
        // 홈 탭으로 이동 (0번 인덱스)
        navigateToTab(0)
        
        // 현재 네비게이션 컨트롤러 가져오기
        guard let navigationController = currentNavigationController() else { return }
        
        // 이미 JourneyDetailViewController가 스택에 있는지 확인
        let existingDetailVC = navigationController.viewControllers.first { vc in
            if let detailVC = vc as? JourneyDetailViewController {
                return detailVC.journey == journey
            }
            return false
        }
        
        if let detailVC = existingDetailVC {
            // 있으면 해당 뷰 컨트롤러까지 팝
            navigationController.popToViewController(detailVC, animated: true)
        } else {
            // 없으면 새로 푸시
            let journeyDetailViewController = JourneyDetailViewController()
            journeyDetailViewController.journey = journey
            navigationController.pushViewController(journeyDetailViewController, animated: true)
        }
    }
    
    // 특정 탭으로 이동
    func navigateToTab(_ index: Int) {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return }
        DispatchQueue.main.async {
            tabBarController.selectedIndex = index
        }
    }
    
    // 특정 뷰 컨트롤러 푸시
    func push(_ viewController: UIViewController, animated: Bool = true) {
        guard let navigationController = currentNavigationController() else { return }
        DispatchQueue.main.async {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    // 현재 네비게이션 컨트롤러 반환
    private func currentNavigationController() -> UINavigationController? {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return nil }
        
        if let navigationController = tabBarController.selectedViewController as? UINavigationController {
            return navigationController
        }
        
        return nil
    }
}
