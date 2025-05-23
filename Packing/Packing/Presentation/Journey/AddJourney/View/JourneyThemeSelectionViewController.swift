//
//  JourneyThemeSelectionViewController.swift
//  Packing
//
//  Created by 이융의 on 4/17/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class JourneyThemeSelectionViewController: UIViewController, View {
    
    // MARK: - Properties
    typealias Reactor = JourneyThemeSelectionReactor
    
    var disposeBag = DisposeBag()
    
    private lazy var navigationTitleLabel: UILabel = {
        let label = UILabel()
        let attachmentString = NSMutableAttributedString(string: "")
        let imageAttachment: NSTextAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "logoIconWhite")
        let isSmallDevice = UIScreen.main.bounds.height < 700
        let iconSize: CGFloat = isSmallDevice ? 20 : 24
        imageAttachment.bounds = CGRect(x: 0, y: -6, width: iconSize, height: iconSize)
        attachmentString.append(NSAttributedString(attachment: imageAttachment))
        attachmentString.append(NSAttributedString(string: " 패킹".localized))
        label.attributedText = attachmentString
        label.sizeToFit()
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: isSmallDevice ? 18 : 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let planProgressBar: PlanProgressBar = {
        let progressBar = PlanProgressBar(progress: 2)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "여행 테마를 선택해주세요".localized
        let isSmallDevice = UIScreen.main.bounds.height < 700
        label.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 17, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "여러 개 선택할 수 있어요!".localized
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var themeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        // iPad 여부에 따라 간격 조정
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        layout.minimumLineSpacing = isIPad ? 20 : 15
        layout.minimumInteritemSpacing = isIPad ? 20 : 10
        
        // iPad에서 여백 추가
        if isIPad {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        } else {
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        collectionView.isScrollEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ThemeCell.self, forCellWithReuseIdentifier: "ThemeCell")
        
        return collectionView
    }()
    
    private let helperLabel: UILabel = {
        let label = UILabel()
        label.text = "여행에 딱 맞는 준비물을 추천해드릴게요!".localized
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.asColor(targetString: "딱 맞는 준비물".localized, color: .main)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 8
        let isSmallDevice = UIScreen.main.bounds.height < 700
        button.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 15 : 16, weight: .medium)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.viewDidAppear)
    }
    
    func bind(reactor: Reactor) {
        // Action
        // 테마 셀 선택 처리
        themeCollectionView.rx.itemSelected
            .map { indexPath in
                let theme = reactor.currentState.themeTemplates[indexPath.item].themeName
                return Reactor.Action.toggleTheme(theme)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 처리
        nextButton.rx.tap
            .map { Reactor.Action.next }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        // 테마 컬렉션뷰 데이터 바인딩
        reactor.state.map { $0.themeTemplates }
            .observe(on: MainScheduler.instance)
            .bind(to: themeCollectionView.rx.items(cellIdentifier: "ThemeCell", cellType: ThemeCell.self)) { indexPath, template, cell in
                let isSelected = reactor.currentState.selectedThemes.contains(template.themeName)
                cell.configure(with: template, isSelected: isSelected)
            }
            .disposed(by: disposeBag)
        
        // 선택된 테마 상태 업데이트
        reactor.state.map { $0.selectedThemes }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.themeCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 활성화 상태 업데이트
        reactor.state.map { $0.canProceed }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] canProceed in
                self?.nextButton.isEnabled = canProceed
                self?.nextButton.backgroundColor = canProceed ? .black : .lightGray
            })
            .disposed(by: disposeBag)
        
        // Collection view delegate 설정
        themeCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationTitleLabel)
        view.backgroundColor = .systemGray6
        
        // 디바이스 타입 확인
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let isSmallDevice = UIScreen.main.bounds.height < 700
        
        // iPad에서는 더 큰 컨테이너 높이 사용
        let containerHeight: CGFloat
        if isIPad {
            // iPad 화면 높이에 따라 조정
            let screenHeight = UIScreen.main.bounds.height
            
            if screenHeight < 900 { // iPad mini (8.3")
                containerHeight = 560
            } else if screenHeight < 1000 { // iPad Air/Pro 11"
                containerHeight = 620
            } else { // iPad Pro 12.9"
                containerHeight = 680
            }
        } else {
            containerHeight = isSmallDevice ? 430 : 530
        }
        
        // Add progress bar
        view.addSubview(planProgressBar)
        
        // Add container view
        view.addSubview(containerView)
        
        // Add question label to container
        containerView.addSubview(questionLabel)
        containerView.addSubview(subtitleLabel)
        
        // Add collection view
        containerView.addSubview(themeCollectionView)
        
        // Add helper label
        view.addSubview(helperLabel)
        
        // Add next button
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            // Progress bar constraints
            planProgressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            planProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            planProgressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            planProgressBar.heightAnchor.constraint(equalToConstant: isSmallDevice ? 15 : 20),

            // Container view constraints
            containerView.topAnchor.constraint(equalTo: planProgressBar.bottomAnchor, constant: isSmallDevice ? 25 : 30),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: containerHeight),

            // Question label constraints
            questionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: isSmallDevice ? 20 : 30),
            questionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Subtitle label constraints
            subtitleLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Collection view constraints
            themeCollectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: isSmallDevice ? 15 : 20),
            themeCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            themeCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            themeCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            // Helper label constraints
            helperLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: isSmallDevice ? 15 : 20),
            helperLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            helperLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Next button constraints
            nextButton.topAnchor.constraint(equalTo: helperLabel.bottomAnchor, constant: isSmallDevice ? 10 : 20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: isSmallDevice ? 45 : 50),
            nextButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }}

// MARK: - UICollectionViewDelegateFlowLayout
extension JourneyThemeSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 디바이스 타입 확인
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let isSmallDevice = UIScreen.main.bounds.height < 700
        
        // iPad에서는 화면 크기에 따라 동적으로 셀 크기 조정
        if isIPad {
            let screenWidth = UIScreen.main.bounds.width
            
            // iPad 크기별로 다르게 적용
            let itemsPerRow: CGFloat = 3 // 기본적으로 한 줄에 3개의 아이템
            let spacing: CGFloat = 10 // 아이템 간격
            
            // 가로 너비에 따라 셀 크기 조정
            let width: CGFloat
            
            if screenWidth > 1000 { // 큰 iPad Pro (12.9")
                width = (collectionView.bounds.width - (spacing * (itemsPerRow - 1))) / itemsPerRow * 0.75
            } else if screenWidth > 800 { // iPad Air/Pro 11"
                width = (collectionView.bounds.width - (spacing * (itemsPerRow - 1))) / itemsPerRow * 0.85
            } else { // iPad mini
                width = (collectionView.bounds.width - (spacing * (itemsPerRow - 1))) / itemsPerRow * 0.95
            }
            
            // 아이템 높이는, 이미지(정사각형) + 타이틀 라벨 + 여백
            let height = width + 30 // 이미지 + 텍스트 영역 (여백 증가)
            
            return CGSize(width: width, height: height)
        } else {
            // 기존 iPhone 로직 유지 (여백 증가)
            let width = (collectionView.bounds.width - 20) / 3
            return CGSize(width: width, height: width + 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // iPad에서는 더 큰 간격 사용
        return UIDevice.current.userInterfaceIdiom == .pad ? 25 : 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // iPad에서는 더 큰 간격 사용
        return UIDevice.current.userInterfaceIdiom == .pad ? 20 : 10
    }
}
