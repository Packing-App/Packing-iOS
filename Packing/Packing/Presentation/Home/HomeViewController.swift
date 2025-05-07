//
//  HomeViewController.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

class HomeViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    typealias Reactor = HomeViewReactor
    
    // 커스텀 데이터 소스 생성 (일반 여행 + 빈 셀 지원)
    private lazy var journeyDataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Journey?>>(
        configureCell: { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TravelPlanCell", for: indexPath) as! TravelPlanCell
            cell.configure(with: item) // 수정된 셀은 nil도 처리 가능
            return cell
        }
    )

    // MARK: - UI COMPONENTS
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var navigationTitleLabel: UILabel = {
        let label = UILabel()
        let attachmentString = NSMutableAttributedString(string: "")
        let imageAttachment: NSTextAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "logoIconWhite")
        imageAttachment.bounds = CGRect(x: 0, y: -7, width: 24, height: 24)
        attachmentString.append(NSAttributedString(attachment: imageAttachment))
        attachmentString.append(NSAttributedString(string: " PACKING"))
        label.attributedText = attachmentString
        label.sizeToFit()
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - 상단 디자인 UI Components
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "background"))
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var planeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "plane"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var planeCloudImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "planeCloud"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var planeCloudTwoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "planeCloud2"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addNewJourneyButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = UIColor(hexCode: "333A56")
        configuration.baseBackgroundColor = .white
        configuration.buttonSize = .large
        configuration.title = "새로운 여행 준비하기"
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
            return outgoing
        }
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        configuration.background.strokeColor = UIColor(hexCode: "B0DCF0")
        configuration.background.strokeWidth = 2.5
        
        let button = UIButton(configuration: configuration)
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.clipsToBounds = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // My Travel Plan Section
    private lazy var myTravelPlansSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var myTravelPlansSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var travelPlansCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 180, height: 180)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TravelPlanCell.self, forCellWithReuseIdentifier: "TravelPlanCell")

        return collectionView
    }()
    
    // Templates Section
    private lazy var templatesSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var templatesSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "테마별 여행 준비물 모음"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var templatesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        // 화면 크기에 따라 다른 방식 적용
        let screenWidth = UIScreen.main.bounds.width
        
        let itemWidth: CGFloat
        if screenWidth > 428 {
            itemWidth = 110 // Pro Max에서는 고정 너비 사용
        } else {
            itemWidth = (screenWidth - 60) / 3 // 기존 계산법 유지
        }
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 30)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TemplateCell.self, forCellWithReuseIdentifier: "TemplateCell")
        
        return collectionView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - INITIALIZE
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let journeyService = JourneyService()
        let reactor = HomeViewReactor(journeyService: journeyService)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAllAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()

        // 화면이 나타날 때마다 최신 데이터 로드
        reactor?.action.onNext(.refreshJourneys)
        
        // 사용자 이름 업데이트
        updateUserNameLabels()
    }
    
    func bind(reactor: HomeViewReactor) {
        bindNotificationButton(reactor: reactor)

        // Action 바인딩
        
        // 화면 로드 시 여행 목록 가져오기
        Observable.just(())
            .map { HomeViewReactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 새 여행 버튼 클릭
        addNewJourneyButton.rx.tap
            .map { HomeViewReactor.Action.addNewJourney }
            .subscribe(onNext: { [weak self] _ in
                guard let navigationController = self?.navigationController else { return }
                JourneyCreationCoordinator.shared.startJourneyCreation(from: navigationController)
            })
            .disposed(by: disposeBag)
        
        templatesCollectionView.rx.modelSelected(ThemeListModel.self)
            .subscribe(onNext: { [weak self] theme in
                let themeTemplateVC = ThemeTemplateViewController()
                themeTemplateVC.themeName = theme.themeName
                themeTemplateVC.reactor = ThemeTemplateReactor()
                self?.navigationController?.pushViewController(themeTemplateVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 데이터 바인딩 (마지막에 nil 추가)
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { state -> [SectionModel<String, Journey?>] in
                let items = state.journeys.map { $0 as Journey? } + [nil] // 마지막에 nil 추가
                return [SectionModel(model: "Journeys", items: items)]
            }
            .bind(to: travelPlansCollectionView.rx.items(dataSource: journeyDataSource))
            .disposed(by: disposeBag)

        // 셀 선택 처리 (여행 셀 vs 추가 버튼 구분)
        travelPlansCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let cell = self?.travelPlansCollectionView.cellForItem(at: indexPath) as? TravelPlanCell
                
                if let isAddCell = cell?.isAddJourneyCell(), isAddCell {
                    // "추가" 셀 클릭 처리
                    guard let navigationController = self?.navigationController else { return }
                    JourneyCreationCoordinator.shared.startJourneyCreation(from: navigationController)
                } else {
                    // 일반 여행 셀 클릭 처리
                    let journeys = reactor.currentState.journeys
                    if indexPath.item < journeys.count {
                        let journey = journeys[indexPath.item]
                        let detailVC = JourneyDetailViewController()
                        detailVC.journey = journey
                        self?.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        // State 바인딩
        
        // 테마 템플릿 바인딩
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.themeTemplates }
            .bind(to: templatesCollectionView.rx.items(cellIdentifier: "TemplateCell", cellType: TemplateCell.self)) { indexPath, template, cell in
                cell.configure(with: template)
            }
            .disposed(by: disposeBag)
        
        // 로딩 상태 바인딩
        reactor.state
            .observe(on: MainScheduler.instance)
            .map{ $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        // 에러 바인딩
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.error }
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
            .subscribe(onNext: { [weak self] error in
                if let error = error {
                    // 에러 알림 표시
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - SETUP
    
    private func setupUI() {
        view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: navigationTitleLabel)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: notificationButton)
        self.navigationController?.navigationBar.tintColor = .white

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        // 스크롤뷰의 bounces 속성을 false로 설정하여 바운스 효과를 제거
        scrollView.bounces = false
        // 배경 이미지 먼저 추가
        contentView.addSubview(backgroundImageView)
        
        // 그 위에 UI 요소들 추가
        contentView.addSubview(planeCloudTwoImageView)
        contentView.addSubview(planeImageView)
        contentView.addSubview(planeCloudImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(addNewJourneyButton)
        
        contentView.addSubview(myTravelPlansSectionView)
        contentView.addSubview(templatesSectionView)
        contentView.addSubview(loadingIndicator)
        
        myTravelPlansSectionView.addSubview(myTravelPlansSectionLabel)
        myTravelPlansSectionView.addSubview(travelPlansCollectionView)
        
        templatesSectionView.addSubview(templatesSectionLabel)
        templatesSectionView.addSubview(templatesCollectionView)
        
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: templatesSectionView.bottomAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 로딩 인디케이터
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 배경 이미지 제약조건
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -10),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 280), // 적절한 높이로 조정
            
            planeImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            planeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            planeImageView.widthAnchor.constraint(equalToConstant: 80),
            planeImageView.heightAnchor.constraint(equalToConstant: 40),
            
            planeCloudImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            planeCloudImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            planeCloudImageView.widthAnchor.constraint(equalToConstant: 80),
            planeCloudImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: planeImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            planeCloudTwoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            planeCloudTwoImageView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10),
            planeCloudTwoImageView.widthAnchor.constraint(equalToConstant: 50),
            planeCloudTwoImageView.heightAnchor.constraint(equalToConstant: 20),
            
            addNewJourneyButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addNewJourneyButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            addNewJourneyButton.heightAnchor.constraint(equalToConstant: 54),
            addNewJourneyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            addNewJourneyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            // myTravelPlansSection
            myTravelPlansSectionView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 20),
            myTravelPlansSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            myTravelPlansSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            myTravelPlansSectionLabel.topAnchor.constraint(equalTo: myTravelPlansSectionView.topAnchor, constant: 20),
            myTravelPlansSectionLabel.leadingAnchor.constraint(equalTo: myTravelPlansSectionView.leadingAnchor, constant: 20),
            myTravelPlansSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),

            travelPlansCollectionView.topAnchor.constraint(equalTo: myTravelPlansSectionLabel.bottomAnchor, constant: 15),
            travelPlansCollectionView.leadingAnchor.constraint(equalTo: myTravelPlansSectionView.leadingAnchor),
            travelPlansCollectionView.trailingAnchor.constraint(equalTo: myTravelPlansSectionView.trailingAnchor),
            travelPlansCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            travelPlansCollectionView.bottomAnchor.constraint(equalTo: myTravelPlansSectionView.bottomAnchor, constant: -10),
            
            // TemplatesSection
            templatesSectionView.topAnchor.constraint(equalTo: myTravelPlansSectionView.bottomAnchor, constant: 0),
            templatesSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            templatesSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            templatesSectionLabel.topAnchor.constraint(equalTo: templatesSectionView.topAnchor, constant: 20),
            templatesSectionLabel.leadingAnchor.constraint(equalTo: templatesSectionView.leadingAnchor, constant: 20),
            
            templatesCollectionView.topAnchor.constraint(equalTo: templatesSectionLabel.bottomAnchor, constant: 20),
            templatesCollectionView.leadingAnchor.constraint(equalTo: templatesSectionView.leadingAnchor, constant: 20),
            templatesCollectionView.trailingAnchor.constraint(equalTo: templatesSectionView.trailingAnchor, constant: -20),
            templatesCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 450),
            templatesCollectionView.bottomAnchor.constraint(equalTo: templatesSectionView.bottomAnchor, constant: -10)
        ])
    }
    
    private func updateUserNameLabels() {
        if let name = UserManager.shared.currentUser?.name {
            // 타이틀 레이블 업데이트
            titleLabel.text = "\(name)님!\n여행 준비를 같이 해볼까요?"
            
            // 여행 계획 섹션 레이블 업데이트
            myTravelPlansSectionLabel.text = "\(name)님의 여행 계획"
        } else {
            titleLabel.text = "회원님!\n여행 준비를 같이 해볼까요?"
            myTravelPlansSectionLabel.text = "회원님의 여행 계획"
        }
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .main
        
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// Add these animations to enhance the user experience
extension HomeViewController {
    
    func animateHeaderElements() {
        // Initially set alpha to 0 for elements to animate (버튼 제외)
        planeImageView.alpha = 0
        planeCloudImageView.alpha = 0
        planeCloudTwoImageView.alpha = 0
        titleLabel.alpha = 0
        
        // Animate plane flying in
        UIView.animate(withDuration: 1.0, delay: 0.2, options: [.curveEaseOut], animations: {
            self.planeImageView.alpha = 1
            self.planeImageView.transform = CGAffineTransform(translationX: -20, y: 0)
        })
        
        // Animate clouds appearing
        UIView.animate(withDuration: 0.8, delay: 0.4, options: [.curveEaseOut], animations: {
            self.planeCloudImageView.alpha = 1
        })
        
        UIView.animate(withDuration: 0.8, delay: 0.5, options: [.curveEaseOut], animations: {
            self.planeCloudTwoImageView.alpha = 1
        })
        
        // Animate title appearing
        UIView.animate(withDuration: 0.8, delay: 0.6, options: [.curveEaseOut], animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -10)
        })
        
        // 버튼은 확대-축소 애니메이션만 적용
        UIView.animate(withDuration: 0.8, delay: 0.8, options: [.curveEaseOut], animations: {
            self.addNewJourneyButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.addNewJourneyButton.transform = .identity
            })
        })
    }
    
    // Call this when setting up UI
    func setupCloudAnimation() {
        // Setup repeated cloud animation
        let cloudAnimation = CABasicAnimation(keyPath: "position.x")
        cloudAnimation.fromValue = planeCloudTwoImageView.layer.position.x - 10
        cloudAnimation.toValue = planeCloudTwoImageView.layer.position.x + 10
        cloudAnimation.duration = 3.0
        cloudAnimation.repeatCount = .infinity
        cloudAnimation.autoreverses = true
        cloudAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        planeCloudTwoImageView.layer.add(cloudAnimation, forKey: "floatingCloud")
    }
    
    // Make the Add Journey button pulse to draw attention
    func setupAddButtonPulse() {
        let pulseAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 0.6
        pulseAnimation.duration = 1.2
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.autoreverses = true
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        addNewJourneyButton.layer.add(pulseAnimation, forKey: "pulseAnimation")
    }
    
    // Add to viewDidLoad
    func setupAllAnimations() {
        // Setup initial states
        planeImageView.alpha = 0
        planeCloudImageView.alpha = 0
        planeCloudTwoImageView.alpha = 0
        titleLabel.alpha = 0
        addNewJourneyButton.alpha = 1
        
        // Setup animations that will be triggered later
        setupCloudAnimation()
        setupAddButtonPulse()
    }
    
    // Add this to your class
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateHeaderElements()
    }
}

// MARK: - HomeViewController의 알림 버튼 연결 부분
extension HomeViewController {
    
    // MARK: - 알림 버튼 연결 메서드
    func setupNotificationButton() {
        // 알림 버튼 탭 이벤트 처리
        notificationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showNotificationsScreen()
            })
            .disposed(by: disposeBag)
    }
    
    // 알림 화면 표시 메서드
    private func showNotificationsScreen() {
        let notificationService = NotificationService(apiClient: APIClient.shared)
        let journeyService: JourneyServiceProtocol = JourneyService()
        let notificationsReactor = NotificationsReactor(notificationService: notificationService, journeyService: journeyService)
        
        let notificationsViewController = NotificationsViewController(reactor: notificationsReactor)
        notificationsViewController.reactor = notificationsReactor
        
        navigationController?.pushViewController(notificationsViewController, animated: true)
    }
}

extension HomeViewController {
    // 기존 bind 메서드에 추가할 부분
    func bindNotificationButton(reactor: HomeViewReactor) {
        // 알림 버튼 설정
        setupNotificationButton()
        
        // 화면이 나타날 때마다 읽지 않은 알림 수 업데이트
        rx.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                self?.updateUnreadNotificationCount()
            })
            .disposed(by: disposeBag)
    }
    
    // 읽지 않은 알림 수 업데이트 메서드
    private func updateUnreadNotificationCount() {
        // 기존 구현된 NotificationService 사용
        let notificationService = NotificationService(apiClient: APIClient.shared)
        
        // 읽지 않은 알림 수 가져오기
        notificationService.getUnreadCount()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] count in
                // 읽지 않은 알림이 있을 경우 배지 표시
                self?.updateNotificationBadge(count: count)
            }, onError: { error in
                print("읽지 않은 알림 수 조회 오류: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // 알림 버튼 배지 업데이트
    private func updateNotificationBadge(count: Int) {
        if count > 0 {
            // 배지 표시를 위한 UIView 생성
            let badgeView = UIView()
            badgeView.backgroundColor = .systemRed
            badgeView.layer.cornerRadius = 8
            badgeView.tag = 999  // 기존 배지 제거를 위한 태그 설정
            
            // 기존 배지 제거
            notificationButton.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            
            // 배지 레이블 설정
            let badgeLabel = UILabel()
            badgeLabel.text = count > 99 ? "99+" : "\(count)"
            badgeLabel.textColor = .white
            badgeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            badgeLabel.textAlignment = .center
            
            // 배지 레이아웃 설정
            notificationButton.addSubview(badgeView)
            badgeView.addSubview(badgeLabel)
            
            badgeView.translatesAutoresizingMaskIntoConstraints = false
            badgeLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // 배지 위치 설정 - 버튼의 오른쪽 상단
            NSLayoutConstraint.activate([
                badgeView.topAnchor.constraint(equalTo: notificationButton.topAnchor, constant: -5),
                badgeView.trailingAnchor.constraint(equalTo: notificationButton.trailingAnchor, constant: 5),
                badgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
                badgeView.heightAnchor.constraint(equalToConstant: 16),
                
                badgeLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
                badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                badgeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: badgeView.leadingAnchor, constant: 2),
                badgeLabel.trailingAnchor.constraint(lessThanOrEqualTo: badgeView.trailingAnchor, constant: -2)
            ])
        } else {
            // 읽지 않은 알림이 없으면 배지 제거
            notificationButton.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        }
    }
}

extension Reactive where Base: UIViewController {
    var viewWillAppear: Observable<Bool> {
        return methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { $0.first as? Bool ?? false }
    }
}
