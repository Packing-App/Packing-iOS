//
//  SceneDelegate.swift
//  Packing
//
//  Created by 이융의 on 3/24/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Thread.sleep(forTimeInterval: 1.0) // 스플래시 화면 표시 시간
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let userManager = UserManager.shared
        
        // 로그인 상태에 따라 다른 화면으로 이동
        if userManager.currentUser != nil {
            // 로그인된 상태 - 탭바 컨트롤러 설정
            setupTabBarController()
        } else {
            // 로그인되지 않은 상태 - 로그인 화면으로 이동
            let loginViewController = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginViewController)
            navigationController.isNavigationBarHidden = true
            window?.rootViewController = navigationController
        }
        
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
    }
    
    // 탭바 컨트롤러 설정 메서드
    private func setupTabBarController() {
        let tabBarController = UITabBarController()
        
        // 홈 탭
        let homeViewController = HomeViewController()
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        homeViewController.title = "내 여행"
        homeNavigationController.tabBarItem = UITabBarItem(
            title: "내 여행",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // 마이페이지 탭
        let myPageViewController = MyPageViewController()
        let myPageNavigationController = UINavigationController(rootViewController: myPageViewController)
        myPageViewController.title = "프로필"
        myPageNavigationController.tabBarItem = UITabBarItem(
            title: "프로필",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        // 탭바에 네비게이션 컨트롤러 추가
        tabBarController.viewControllers = [homeNavigationController, myPageNavigationController]
        
        // iOS 15 이상에서 탭바 스타일 설정
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            tabBarController.tabBar.standardAppearance = appearance
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        
        window?.rootViewController = tabBarController
    }
    
    
    //    private lazy var homeTabButton: UIButton = {
    //        let button = UIButton(type: .system)
    //        button.setImage(UIImage(systemName: "house.fill"), for: .normal)
    //        button.tintColor = .main
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //
    //        let label = UILabel()
    //        label.text = "홈"
    //        label.font = .systemFont(ofSize: 12)
    //        label.textColor = .main
    //        label.textAlignment = .center
    //        label.translatesAutoresizingMaskIntoConstraints = false
    //
    //        button.addSubview(label)
    //
    //        NSLayoutConstraint.activate([
    //            label.topAnchor.constraint(equalTo: button.centerYAnchor, constant: 10),
    //            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
    //            label.widthAnchor.constraint(equalToConstant: 40)
    //        ])
    //
    //        return button
    //    }()
    //
    //    private lazy var profileTabButton: UIButton = {
    //        let button = UIButton(type: .system)
    //        button.setImage(UIImage(systemName: "person"), for: .normal)
    //        button.tintColor = .lightGray
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //
    //        let label = UILabel()
    //        label.text = "마이"
    //        label.font = .systemFont(ofSize: 12)
    //        label.textColor = .lightGray
    //        label.textAlignment = .center
    //        label.translatesAutoresizingMaskIntoConstraints = false
    //
    //        button.addSubview(label)
    //
    //        NSLayoutConstraint.activate([
    //            label.topAnchor.constraint(equalTo: button.centerYAnchor, constant: 10),
    //            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
    //            label.widthAnchor.constraint(equalToConstant: 40)
    //        ])
    //
    //        return button
    //    }()
//    private lazy var tabBar: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
//        view.layer.shadowOffset = CGSize(width: 0, height: -2)
//        view.layer.shadowRadius = 4
//        view.layer.shadowOpacity = 0.5
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
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

