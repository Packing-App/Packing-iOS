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

///// 인증 관련 코디네이터 프로토콜
//protocol AuthCoordinatorProtocol: Coordinator {
//    func navigateToLogin()
//}

// MARK: - AuthCoordinator Implementation

/// 인증 흐름을 관리하는 코디네이터
class AuthCoordinator {
    
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
    
    private var isGuestMode: Bool = false

    // 여행 생성 컨텍스트 (로그인 후 돌아갈 곳 추적)
    private var savedJourneyCreationNavigation: UINavigationController?

    // 추가할 메서드 - 게스트 모드로 여행 생성 시작
    func startGuestJourneyCreation(from navigationController: UINavigationController?) {
        guard let navigationController = navigationController else { return }
        
        // 게스트 모드 설정
        isGuestMode = true
        
        // JourneyCreationCoordinator를 통해 여행 생성 플로우 시작
        JourneyCreationCoordinator.shared.startJourneyCreation(from: navigationController)
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
    func navigateToLogin(isFromJourneyCreation: Bool = false, journeyNavigation: UINavigationController? = nil) {
        // 토큰 관련 데이터 정리 (기존 코드 유지)
        UserManager.shared.logout()
        
        // 여행 생성 컨텍스트 저장
        if isFromJourneyCreation, let navigation = journeyNavigation {
            savedJourneyCreationNavigation = navigation
            UserDefaults.standard.set(true, forKey: "isLoginFromJourneyCreation")
        } else {
            savedJourneyCreationNavigation = nil
            UserDefaults.standard.removeObject(forKey: "isLoginFromJourneyCreation")
        }

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
    
    func continueJourneyCreationAfterLogin() {
        isGuestMode = false
        
        if let navigationController = savedJourneyCreationNavigation {
            // 로그인 후 화면 전환 전에 약간의 딜레이 추가 (상태 업데이트 완료를 위해)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                
                // 저장된 네비게이션 컨트롤러로 돌아가기
                self.window?.rootViewController = navigationController
                
                // JourneyCreationCoordinator에게 로그인 완료 알림
                JourneyCreationCoordinator.shared.continueAfterLogin(from: navigationController)
                
                // 명시적으로 화면 다시 로드 요청 (로그인 상태 반영을 위해)
                NotificationCenter.default.post(name: NSNotification.Name("UserLoginStatusChanged"), object: nil)
            }
        } else {
            // 저장된 네비게이션이 없으면 메인 화면으로
            showMainScreen()
        }
        
        // 저장된 컨텍스트 초기화
        savedJourneyCreationNavigation = nil
        UserDefaults.standard.removeObject(forKey: "isLoginFromJourneyCreation")
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
                title: "내 여행".localized,
                image: UIImage(systemName: "house"),
                selectedImage: UIImage(systemName: "house.fill")
            )
            
            // 친구목록 탭
            let friendsViewController = FriendsViewController()
            let friendsNavigationController = UINavigationController(rootViewController: friendsViewController)
            friendsNavigationController.tabBarItem = UITabBarItem(
                title: "내 친구".localized,
                image: UIImage(systemName: "person.2"),
                selectedImage: UIImage(systemName: "person.2.fill")
            )
            
            // 마이페이지 탭
            let profileReactor = ProfileViewReactor()
            let profileViewController = ProfileViewController(reactor: profileReactor)
            let profileNavigationController = UINavigationController(rootViewController: profileViewController)
            profileNavigationController.tabBarItem = UITabBarItem(
                title: "내 프로필".localized,
                image: UIImage(systemName: "person"),
                selectedImage: UIImage(systemName: "person.fill")
            )
            
            // 탭바에 네비게이션 컨트롤러 추가
            tabBarController.viewControllers = [homeNavigationController, friendsNavigationController, profileNavigationController]
            
            // iOS 15 이상에서 탭바 스타일 설정
            if #available(iOS 15.0, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithDefaultBackground()
                appearance.stackedLayoutAppearance.selected.iconColor = .main
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.main]

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
