//
//  JourneyTransportTypeSelectionViewController.swift
//  Packing
//
//  Created by 이융의 on 4/17/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class JourneyTransportTypeSelectionViewController: UIViewController, View {
    
    // MARK: - Properties
    typealias Reactor = JourneyTransportTypeSelectionReactor
    
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
        let progressBar = PlanProgressBar(progress: 0)
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
        label.text = "여행을 어떻게 가시나요?"
        let isSmallDevice = UIScreen.main.bounds.height < 700
        label.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 17, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transportStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        let isSmallDevice = UIScreen.main.bounds.height < 700
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("건너뛰기", for: .normal)
        button.setTitleColor(.main, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray // Start with disabled state
        button.layer.cornerRadius = 8
        let isSmallDevice = UIScreen.main.bounds.height < 700
        button.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 15 : 16, weight: .medium)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var transportOptionViews = [UIView]()
    private var selectedTransportOption: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTransportOptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.viewDidAppear)
    }
    
    func bind(reactor: Reactor) {
        // 다음 버튼 탭 바인딩
        nextButton.rx.tap
            .do(onNext: { _ in
                print(#fileID, #function, #line, "- ")
                print("다음 버튼 탭됨!")
            })
            .map { Reactor.Action.next }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 건너뛰기 버튼 탭 바인딩
        skipButton.rx.tap
            .do(onNext: { _ in
                print("건너뛰기 버튼 탭됨!")
            })
            .map { Reactor.Action.skip }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State 바인딩
        // 선택된 운송 수단에 따라 UI 업데이트
        reactor.state.map { $0.selectedTransportType }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] type in
                if let type = type, let index = TransportType.allCases.firstIndex(of: type) {
                    self?.updateTransportSelection(at: index)
                }
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
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationTitleLabel)
        
        view.backgroundColor = .systemGray6
        
        // 디바이스 크기에 따른 조정
        let isSmallDevice = UIScreen.main.bounds.height < 700
        let containerHeight: CGFloat = isSmallDevice ? 360 : 450
        
        // Add progress bar
        view.addSubview(planProgressBar)
        
        // Add container view
        view.addSubview(containerView)
        
        // Add question label to container
        containerView.addSubview(questionLabel)
        
        // Add transport stack view
        containerView.addSubview(transportStackView)
        
        // Add skip button
        view.addSubview(skipButton)
        
        // Add next button
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            // Progress bar constraints
            planProgressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            planProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            planProgressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            planProgressBar.heightAnchor.constraint(equalToConstant: isSmallDevice ? 15 : 20),
            
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: planProgressBar.bottomAnchor, constant: 40),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: containerHeight),
            
            // Question label constraints
            questionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: isSmallDevice ? 20 : 30),
            questionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Transport stack view constraints
            transportStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: isSmallDevice ? 15 : 20),
            transportStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: isSmallDevice ? 20 : 30),
            transportStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: isSmallDevice ? -20 : -30),
            transportStackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            
            // Skip button constraints
            skipButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Next button constraints - 모든 화면에서 보이도록 조정
            nextButton.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            nextButton.heightAnchor.constraint(equalToConstant: isSmallDevice ? 45 : 50)
        ])
    }
    
    private func configureTransportOptions() {
        let transportOptions = [
            ("airplane", "비행기"),
            ("tram", "기차"),
            ("ferry", "배"),
            ("bus", "버스"),
            ("figure.walk", "도보"),
            ("ellipsis", "기타")
        ]
        
        // TransportType.allCases와 크기가 동일한지 확인
        assert(transportOptions.count == TransportType.allCases.count, "transportOptions와 TransportType.allCases의 개수가 일치해야 합니다")
        
        let isSmallDevice = UIScreen.main.bounds.height < 700
        
        for (i, (icon, title)) in transportOptions.enumerated() {
            // transportType을 직접 연결하여 인덱스 문제 방지
            let transportType = TransportType.allCases[i]
            
            // 옵션 뷰 생성
            let optionView = createTransportOptionButton(icon: icon, title: title)
            
            // 태그에 인덱스 저장하여 인덱스 문제 방지
            optionView.tag = i + 100 // 다른 태그와 충돌 방지를 위해 오프셋 추가
            
            // 탭 제스처 추가
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(transportOptionTapped(_:)))
            optionView.addGestureRecognizer(tapGesture)
            optionView.isUserInteractionEnabled = true
            
            transportStackView.addArrangedSubview(optionView)
            transportOptionViews.append(optionView)
        }
        
        // 초기 선택 상태 적용 (있는 경우)
        if let selectedType = reactor?.currentState.selectedTransportType,
           let index = TransportType.allCases.firstIndex(of: selectedType) {
            updateTransportSelection(at: index)
        }
    }
    
    @objc private func transportOptionTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        
        // 태그에서 인덱스 추출 (오프셋 고려)
        let index = tappedView.tag - 100
        
        print("탭 인식됨: \(index)")
        
        // 범위 체크
        guard index >= 0, index < TransportType.allCases.count else { return }
        
        // 타입 가져오기
        let type = TransportType.allCases[index]
        
        // 리액터에 액션 전송
        reactor?.action.onNext(.selectTransportType(type))
    }
    
    private func createTransportOptionButton(icon: String, title: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let isSmallDevice = UIScreen.main.bounds.height < 700
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = UIColor.main
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: isSmallDevice ? 14 : 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        
        // Store references for later access during selection
        iconImageView.tag = 1001
        titleLabel.tag = 1002
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: isSmallDevice ? 40 : 50),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: isSmallDevice ? 15 : 20),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: isSmallDevice ? 20 : 24),
            iconImageView.heightAnchor.constraint(equalToConstant: isSmallDevice ? 20 : 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: isSmallDevice ? 15 : 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: isSmallDevice ? -15 : -20),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
    
    // 선택된 운송 수단 UI 업데이트
    private func updateTransportSelection(at index: Int) {
        // 모든 옵션 초기화
        for optionView in transportOptionViews {
            optionView.backgroundColor = .white
            optionView.layer.borderColor = UIColor.systemGray5.cgColor
            
            if let iconView = optionView.viewWithTag(1001) as? UIImageView {
                iconView.tintColor = UIColor.main
            }
            
            if let titleLabel = optionView.viewWithTag(1002) as? UILabel {
                titleLabel.textColor = .black
            }
        }
        
        // 인덱스가 범위 내에 있는지 확인
        guard index >= 0, index < transportOptionViews.count else { return }
        
        // 선택된 옵션 강조 표시
        let selectedView = transportOptionViews[index]
        selectedView.backgroundColor = UIColor.main
        selectedView.layer.borderColor = UIColor.main.cgColor
        
        if let iconView = selectedView.viewWithTag(1001) as? UIImageView {
            iconView.tintColor = .white
        }
        
        if let titleLabel = selectedView.viewWithTag(1002) as? UILabel {
            titleLabel.textColor = .white
        }
        
        selectedTransportOption = selectedView
    }
}



