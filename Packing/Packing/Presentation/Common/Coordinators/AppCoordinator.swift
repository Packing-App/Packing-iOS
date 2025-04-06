////
////  AppCoordinator.swift
////  Packing
////
////  Created by 이융의 on 4/6/25.
////
//
//import UIKit
//
//class AppCoordinator {
//    private let window: UIWindow
//    private let tokenManager = KeyChainTokenStorage.shared
//    
//    init(window: UIWindow) {
//        self.window = window
//    }
//    
//    func start() {
//        // 로그인 상태 확인
//        if tokenManager.isLoggedIn {
//            showMainScreen()
//        } else {
//            showLoginScreen()
//        }
//    }
//    
//    private func showLoginScreen() {
//        let authService = AuthService.shared
//        let loginReactor = LoginReactor(authService: authService, presentingViewController: UIViewController())
//        let loginVC = LoginViewController()
//        loginVC.reactor = loginReactor
//        
//        let navigationController = UINavigationController(rootViewController: loginVC)
//        navigationController.isNavigationBarHidden = true
//        
//        window.rootViewController = navigationController
//        window.makeKeyAndVisible()
//    }
//    
//    private func showMainScreen() {
//        let userService = UserService()
//        let authService = AuthService.shared
//        let myPageReactor = MyPageReactor(userService: userService, authService: authService)
//        let myPageVC = MyPageViewController()
//        myPageVC.reactor = myPageReactor
//        
//        let navigationController = UINavigationController(rootViewController: myPageVC)
//        navigationController.isNavigationBarHidden = false
//        
//        window.rootViewController = navigationController
//        window.makeKeyAndVisible()
//    }
//}
