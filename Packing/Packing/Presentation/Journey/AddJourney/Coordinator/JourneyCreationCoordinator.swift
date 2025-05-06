//
//  JourneyCreationCoordinator.swift
//  Packing
//
//  Created by 이융의 on 4/27/25.
//

import ReactorKit
import RxSwift
import RxCocoa
import UIKit

enum JourneyCreationStep {
    case transportType
    case dateSelection
    case themeSelection
    case summary
}

class JourneyCreationCoordinator: NSObject {
    static let shared = JourneyCreationCoordinator()
    private let journeyService: JourneyServiceProtocol
    private let createJourneyReactor: CreateJourneyReactor
    private let disposeBag = DisposeBag()
    
    private(set) var currentStep: JourneyCreationStep = .transportType
    private weak var navigationController: UINavigationController?
    private var createdJourney: Journey?
    private var orientationLock = UIInterfaceOrientationMask.portrait

    private var isGuestMode: Bool {
        return UserManager.shared.currentUser == nil
    }
    
    private override init() {
        self.journeyService = JourneyService()
        self.createJourneyReactor = CreateJourneyReactor(journeyService: journeyService)
        super.init()
        
        self.createJourneyReactor.state
            .map { $0.createdJourney }
            .distinctUntilChanged { $0?.id == $1?.id }
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] journey in
                self?.createdJourney = journey
            })
            .disposed(by: disposeBag)
    }
    
    // 로그인 후 여행 생성 계속하기 메서드
    func continueAfterLogin(from navigation: UINavigationController) {
        self.navigationController = navigation
        
        // 현재 단계가 summary가 아니라면 summary 로 이동 (예외 처리)
        if currentStep != .summary {
            navigateToStep(.summary, animated: false)
        }
        
        // JourneySummaryViewController 가 재로딩 되어야 함을 알림
        NotificationCenter.default.post(name: NSNotification.Name("UserLoginStatusChanged"), object: nil)
    }
    
    func startJourneyCreation(from navigation: UINavigationController) {
        createJourneyReactor.action.onNext(.resetModel)
        createdJourney = nil

        self.navigationController = navigation
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        self.navigationController?.delegate = self
        lockOrientation(.portrait)

        navigateToStep(.transportType, animated: true)
    }
    private func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        orientationLock = orientation
        
        // AppDelegate에서 사용할 수 있도록 알림 발송
        NotificationCenter.default.post(
            name: NSNotification.Name("OrientationLockChanged"),
            object: nil,
            userInfo: ["orientationLock": orientationLock]
        )
    }
    // 현재 설정된 방향 제한 반환
    func getOrientationLock() -> UIInterfaceOrientationMask {
        return orientationLock
    }
    
    func navigateToRecommendations() {
        guard let journey = createdJourney, let navigation = navigationController else { return }
        lockOrientation(.all)
        
        // 게스트 모드에서는 추천 화면으로 진행하지 않음.
        if self.isGuestMode {
            // JourneySummaryReactor 에 로그인 필요 상태 알림
            NotificationCenter.default.post(name: NSNotification.Name("LoginRequiredForJourney"), object: nil)
            return
        }

        let packingItemService = PackingItemService()
        let reactor = RecommendationsReactor(journeyService: journeyService, packingItemService: packingItemService, journey: journey)
        let recommendationsVC = RecommendationsViewController()
        recommendationsVC.reactor = reactor
        navigation.pushViewController(recommendationsVC, animated: true)
    }
    
    func moveToNextStep() {
        switch currentStep {
        case .transportType:
            navigateToStep(.dateSelection, animated: true)
        case .dateSelection:
            navigateToStep(.themeSelection, animated: true)
        case .themeSelection:
            navigateToStep(.summary, animated: true)
        case .summary:
            break
        }
    }
    
    func moveToPreviousStep() {
        guard let navigation = navigationController else { return }
        
        switch currentStep {
        case .transportType:
            break // Already at first step
        case .dateSelection:
            currentStep = .transportType
            navigation.popViewController(animated: true)
        case .themeSelection:
            currentStep = .dateSelection
            navigation.popViewController(animated: true)
        case .summary:
            currentStep = .themeSelection
            navigation.popViewController(animated: true)
        }
    }
    
    private func navigateToStep(_ step: JourneyCreationStep, animated: Bool) {
        guard let navigation = navigationController else { return }
        self.currentStep = step
        
        let viewController: UIViewController
        
        switch step {
        case .transportType:
            let reactor = JourneyTransportTypeSelectionReactor(coordinator: self)
            let vc = JourneyTransportTypeSelectionViewController()
            vc.reactor = reactor
            viewController = vc
        
        case .dateSelection:
            let reactor = JourneyDateSelectionReactor(coordinator: self)
            let vc = JourneyDateSelectionViewController()
            vc.reactor = reactor
            viewController = vc
            
        case .themeSelection:
            let reactor = JourneyThemeSelectionReactor(coordinator: self)
            let vc = JourneyThemeSelectionViewController()
            vc.reactor = reactor
            viewController = vc
            
        case .summary:
            let reactor = JourneySummaryReactor(coordinator: self)
            let vc = JourneySummaryViewController()
            vc.reactor = reactor
            viewController = vc
        }
        
        // Navigation stack management
        if navigation.viewControllers.isEmpty {
            // Initialize the stack with the first screen
            navigation.setViewControllers([viewController], animated: false)
        } else if step == .transportType {
            // Reset to first screen
            navigation.setViewControllers([viewController], animated: animated)
        } else {
            // Check if we already have this step in the stack
            let existingStepIndex = navigation.viewControllers.firstIndex { vc in
                return (vc is JourneyTransportTypeSelectionViewController && step == .transportType) ||
                       (vc is JourneyDateSelectionViewController && step == .dateSelection) ||
                       (vc is JourneyThemeSelectionViewController && step == .themeSelection) ||
                       (vc is JourneySummaryViewController && step == .summary)
            }
            
            if let existingIndex = existingStepIndex {
                // If the step is already in the stack, pop to it
                navigation.popToViewController(navigation.viewControllers[existingIndex], animated: animated)
            } else {
                // Otherwise push the new controller
                navigation.pushViewController(viewController, animated: animated)
            }
        }
    }
    
    
    // MARK: - 중앙 데이터 관리 메서드들
    func getJourneyModel() -> JourneyCreationModel {
        return createJourneyReactor.currentState.journeyModel
    }
    
    func getCreatedJourney() -> Journey? {
        return createdJourney
    }
    
    func updateTransportType(_ type: TransportType) {
        createJourneyReactor.action.onNext(.setTransportType(type))
    }
    
    func updateOrigin(_ origin: String) {
        createJourneyReactor.action.onNext(.setOrigin(origin))
    }
    
    func updateDestination(_ destination: String) {
        createJourneyReactor.action.onNext(.setDestination(destination))
    }
    
    func updateDates(start: Date, end: Date) {
        createJourneyReactor.action.onNext(.setDates(start: start, end: end))
    }
    
    func updateTheme(_ theme: TravelTheme) {
        createJourneyReactor.action.onNext(.setTheme(theme))
    }
    
    func updateTitle(_ title: String) {
        createJourneyReactor.action.onNext(.setTitle(title))
    }
    
    func updateIsPrivate(_ isPrivate: Bool) {
        createJourneyReactor.action.onNext(.setIsPrivate(isPrivate))
    }
    
    func createJourney() -> Observable<Journey?> {
        createJourneyReactor.action.onNext(.createJourney)
        
        // 여행 생성 결과 반환
        return createJourneyReactor.state
            .map { $0.createdJourney }
            .distinctUntilChanged { $0?.id == $1?.id }
            .filter { $0 != nil }
            .take(1)
    }
    
    func isCreatingJourney() -> Observable<Bool> {
        return createJourneyReactor.state
            .map { $0.isCreatingJourney }
            .distinctUntilChanged()
    }
    
    func getError() -> Observable<Error?> {
        return createJourneyReactor.state
            .map { $0.error }
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
    }
}


// MARK: - UINavigationControllerDelegate
extension JourneyCreationCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Update the current step based on the newly visible controller
        if viewController is JourneyTransportTypeSelectionViewController {
            currentStep = .transportType
        } else if viewController is JourneyDateSelectionViewController {
            currentStep = .dateSelection
        } else if viewController is JourneyThemeSelectionViewController {
            currentStep = .themeSelection
        } else if viewController is JourneySummaryViewController {
            currentStep = .summary
        }
    }
}
