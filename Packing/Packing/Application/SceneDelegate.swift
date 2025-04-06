//
//  SceneDelegate.swift
//  Packing
//
//  Created by 이융의 on 3/24/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
//    private var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Thread.sleep(forTimeInterval: 2.0)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
//        let window = UIWindow(windowScene: windowScene)
//        self.window = window
//        appCoordinator = AppCoordinator(window: window)
//        appCoordinator?.start()
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let loginViewReactor = LoginViewReactor()
        let loginViewController = LoginViewController(reactor: loginViewReactor)
        
        // navigation Controller
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.isNavigationBarHidden = true
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
         
    }
/*
    // 소셜 로그인 콜백 URL 처리
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url, url.scheme == "packingapp" {
            // 딥링크 처리
            _ = AuthService.shared.handleDeepLink(url)
                .subscribe(onNext: { tokenData in
                    print("로그인 성공: \(tokenData.user.name)")
                    
                    // MyPage로 이동
                    let userService = UserService()
                    let authService = AuthService.shared
                    let myPageReactor = MyPageReactor(userService: userService, authService: authService)
                    let myPageVC = MyPageViewController()
                    myPageVC.reactor = myPageReactor
                    
                    // 루트 뷰 컨트롤러로 설정 (로그인 스택 제거)
                    let navigationController = UINavigationController(rootViewController: myPageVC)
                    navigationController.isNavigationBarHidden = false
                    self.window?.rootViewController = navigationController
                }, onError: { error in
                    print("로그인 오류: \(error.localizedDescription)")
                })
        }
    }
    */

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

