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
        attachmentString.append(NSAttributedString(string: " PACKING"))
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
        label.text = "여행 테마를 선택해주세요"
        let isSmallDevice = UIScreen.main.bounds.height < 700
        label.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 17, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var themeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ThemeCell.self, forCellWithReuseIdentifier: "ThemeCell")
        
        return collectionView
    }()
    
    private let helperLabel: UILabel = {
        let label = UILabel()
        label.text = "여행에 딱 맞는 준비물을 추천해드릴게요!"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.asColor(targetString: "딱 맞는 준비물", color: .main)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
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
                return Reactor.Action.selectTheme(theme)
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
//            .distinctUntilChanged()
            .bind(to: themeCollectionView.rx.items(cellIdentifier: "ThemeCell", cellType: ThemeCell.self)) { indexPath, template, cell in
                let isSelected = template.themeName == reactor.currentState.selectedTheme
                cell.configure(with: template, isSelected: isSelected)
            }
            .disposed(by: disposeBag)
        
        // 선택된 테마 상태 업데이트
        reactor.state.map { $0.selectedTheme }
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
        
        // Add progress bar
        view.addSubview(planProgressBar)
        
        // Add container view
        view.addSubview(containerView)
        
        // Add question label to container
        containerView.addSubview(questionLabel)
        
        // Add collection view
        containerView.addSubview(themeCollectionView)
        
        // Add helper label
        view.addSubview(helperLabel)
        
        // Add next button
        view.addSubview(nextButton)
        
        let isSmallDevice = UIScreen.main.bounds.height < 700
        let containerHeight: CGFloat = isSmallDevice ? 430 : 500

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
            
            // Collection view constraints
            themeCollectionView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: isSmallDevice ? 15 : 20),
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
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension JourneyThemeSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let isSmallDevice = UIScreen.main.bounds.height < 700
        let width = (collectionView.bounds.width - 20) / 3
        return CGSize(width: width, height: width + 20)
//        let height = isSmallDevice ? (width + 20) : (width + 25)
//        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - Theme Cell
class ThemeCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let isSmallDevice = UIScreen.main.bounds.height < 700
        label.font = UIFont.systemFont(ofSize: isSmallDevice ? 10 : 12)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkmarkView: UIImageView = {
        let imageView = UIImageView()
        let isSmallDevice = UIScreen.main.bounds.height < 700
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.addSubview(overlayView)
        imageView.addSubview(checkmarkView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor), // This makes it square
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            overlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            checkmarkView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.height < 700 ? 24 : 32),
            checkmarkView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height < 700 ? 24 : 32)
        ])
    }
    
    // Override layoutSubviews to update cornerRadius of overlayView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make imageView perfectly circular (if square)
        imageView.layer.cornerRadius = imageView.frame.width / 2
        
        // Make overlayView match imageView's cornerRadius
        overlayView.layer.cornerRadius = imageView.layer.cornerRadius
    }
    
    func configure(with template: ThemeListModel, isSelected: Bool = false) {
        imageView.image = UIImage(named: template.image)
        titleLabel.text = template.themeName.displayName
        
        overlayView.isHidden = !isSelected
        checkmarkView.isHidden = !isSelected
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        overlayView.isHidden = true
        checkmarkView.isHidden = true
    }
}
