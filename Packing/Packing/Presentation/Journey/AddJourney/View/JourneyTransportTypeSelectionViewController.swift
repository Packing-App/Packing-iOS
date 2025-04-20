//
//  JourneyTransportTypeSelectionViewController.swift
//  Packing
//
//  Created by 이융의 on 4/14/25.
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
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transportStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("건너뛰기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var transportOptionButtons = [UIView]()
    private var selectedTransportOption: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTransportOptions()
    }
    
    func bind(reactor: Reactor) {
        // Action
        // 각 운송 수단 옵션에 대한 탭 이벤트 처리
        for (index, option) in transportOptionButtons.enumerated() {
            let tapGesture = UITapGestureRecognizer()
            option.addGestureRecognizer(tapGesture)
            option.isUserInteractionEnabled = true
            
            tapGesture.rx.event
                .map { _ in TransportType.allCases[index] }
                .map { Reactor.Action.selectTransportType($0) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        // 다음 버튼 탭 처리
        nextButton.rx.tap
            .map { Reactor.Action.next }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 건너뛰기 버튼 탭 처리
        skipButton.rx.tap
            .map { Reactor.Action.skip }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        // 선택된 운송 수단에 따라 UI 업데이트
        reactor.state.map { $0.selectedTransportType }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] type in
                guard let self = self, let type = type else { return }
                
                if let index = TransportType.allCases.firstIndex(of: type) {
                    self.updateTransportSelection(at: index)
                }
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 활성화 상태 처리
        reactor.state.map { $0.canProceed }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] canProceed in
                self?.nextButton.isEnabled = canProceed
                self?.nextButton.backgroundColor = canProceed ? .black : .lightGray
            })
            .disposed(by: disposeBag)
        
        // 다음 화면으로 이동
        reactor.state.map { $0.shouldProceed }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigateToDateSelection()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Navigate to next screen
    private func navigateToDateSelection() {
        let dateSelectionReactor = JourneyDateSelectionReactor(parentReactor: reactor!.parentReactor)
        let dateSelectionVC = JourneyDateSelectionViewController()
        dateSelectionVC.reactor = dateSelectionReactor
        navigationController?.pushViewController(dateSelectionVC, animated: true)
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
            planProgressBar.heightAnchor.constraint(equalToConstant: 40),
            
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: planProgressBar.bottomAnchor, constant: 30),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 450),
            
            // Question label constraints
            questionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            questionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Transport stack view constraints
            transportStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            transportStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            transportStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            transportStackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20),
            
            // Skip button constraints
            skipButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Next button constraints
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
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
        
        for (icon, title) in transportOptions {
            let optionButton = createTransportOptionButton(icon: icon, title: title)
            transportStackView.addArrangedSubview(optionButton)
            transportOptionButtons.append(optionButton)
        }
        
        // 이미 선택된 값이 있는 경우 UI 업데이트
        if let selectedType = reactor?.currentState.selectedTransportType,
           let index = TransportType.allCases.firstIndex(of: selectedType) {
            updateTransportSelection(at: index)
        }
    }
    
    private func createTransportOptionButton(icon: String, title: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = UIColor.systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        
        // Store references for later access during selection
        containerView.tag = 1000
        iconImageView.tag = 1001
        titleLabel.tag = 1002
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
    
    private func updateTransportSelection(at index: Int) {
        // Reset all options
        for optionView in transportOptionButtons {
            optionView.backgroundColor = .white
            optionView.layer.borderColor = UIColor.systemGray5.cgColor
            
            if let iconView = optionView.viewWithTag(1001) as? UIImageView {
                iconView.tintColor = UIColor.systemBlue
            }
            
            if let titleLabel = optionView.viewWithTag(1002) as? UILabel {
                titleLabel.textColor = .black
            }
        }
        
        // 선택된 인덱스가 범위 내에 있는지 확인
        guard index >= 0 && index < transportOptionButtons.count else { return }
        
        // 선택된 옵션 강조
        let selectedView = transportOptionButtons[index]
        selectedView.backgroundColor = UIColor.main
        selectedView.layer.borderColor = UIColor.main.cgColor
        
        if let iconView = selectedView.viewWithTag(1001) as? UIImageView {
            iconView.tintColor = .white
        }
        
        if let titleLabel = selectedView.viewWithTag(1002) as? UILabel {
            titleLabel.textColor = .white
        }
        
        // 선택된 옵션 저장
        selectedTransportOption = selectedView
    }
}
