//
//  JourneySummaryViewController.swift
//  Packing
//
//  Created by 이융의 on 4/17/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class JourneySummaryViewController: UIViewController, View {
    
    // MARK: - Properties
    typealias Reactor = JourneySummaryReactor
    
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
        let progressBar = PlanProgressBar(progress: 3)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let journeyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "destination_default") // 기본 이미지
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let participantsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.text = "파티원 1명"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let avatarStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = -10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("초대하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .main
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let infoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateRowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "여행 날짜"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateValueLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜 미설정"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transportRowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let transportLabel: UILabel = {
        let label = UILabel()
        label.text = "여행 테마"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transportValueLabel: UILabel = {
        let label = UILabel()
        label.text = "미설정"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let themeRowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "여행 목적지"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let themeValueLabel: UILabel = {
        let label = UILabel()
        label.text = "미설정"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "여행 제목을 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let privateSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .main
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private let privateSwitchLabel: UILabel = {
        let label = UILabel()
        label.text = "혼자 여행하기"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let helperLabel: UILabel = {
        let label = UILabel()
        label.text = "위 정보가 맞으면 완료 버튼을 눌러주세요"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .main
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAvatars()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.viewDidAppear)
    }
    
    func bind(reactor: Reactor) {
        // Action
        // 제목 입력 처리
        titleTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.setTitle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 비공개 여부 설정 처리
        privateSwitch.rx.isOn
            .distinctUntilChanged()
            .map { Reactor.Action.setIsPrivate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 완료 버튼 탭 처리
        completeButton.rx.tap
            .map { Reactor.Action.createJourney }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 초대하기 버튼 탭 처리
        inviteButton.rx.tap
            .map { Reactor.Action.invite }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        // 여행 모델 정보 표시
        reactor.state.map { $0.transportTypeText }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: transportValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.themeText }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: themeValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.destinationText }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: themeValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.dateRangeText }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: dateValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.title }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: titleTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isPrivate }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: privateSwitch.rx.isOn)
            .disposed(by: disposeBag)
        
        // 로딩 상태 처리
        reactor.state.map { $0.isCreating }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isCreating in
                if isCreating {
                    self?.loadingIndicator.startAnimating()
                    self?.completeButton.isEnabled = false
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.completeButton.isEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        // 오류 처리
        reactor.state.map { $0.error }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(title: "오류", message: error?.localizedDescription ?? "알 수 없는 오류가 발생했습니다.")
            })
            .disposed(by: disposeBag)
        
        // 여행 생성 완료
        reactor.state.map { $0.shouldComplete }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.completeJourneyCreation()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func completeJourneyCreation() {
        (reactor?.coordinator as? JourneyCreationCoordinator)?.navigateToRecommendations()
    }
    
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: completion))
        present(alert, animated: true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationTitleLabel)
        
        view.backgroundColor = .systemGray6
        
        // Add progress bar
        view.addSubview(planProgressBar)
        
        // Add image container and image
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(journeyImageView)
        
        // Add participants container
        view.addSubview(participantsContainer)
        participantsContainer.addSubview(participantsLabel)
        participantsContainer.addSubview(avatarStackView)
        participantsContainer.addSubview(inviteButton)
        
        // Add info container
        view.addSubview(infoContainerView)
        
        // Add date row
        infoContainerView.addSubview(dateRowView)
        dateRowView.addSubview(dateLabel)
        dateRowView.addSubview(dateValueLabel)
        
        // Add transport row
        infoContainerView.addSubview(transportRowView)
        transportRowView.addSubview(transportLabel)
        transportRowView.addSubview(transportValueLabel)
        
        // Add theme row
        infoContainerView.addSubview(themeRowView)
        themeRowView.addSubview(themeLabel)
        themeRowView.addSubview(themeValueLabel)
        
        // Add title text field
        view.addSubview(titleTextField)
        
        // Add private switch
        view.addSubview(privateSwitch)
        view.addSubview(privateSwitchLabel)
        
        // Add helper label
        view.addSubview(helperLabel)
        
        // Add complete button
        view.addSubview(completeButton)
        
        // Add loading indicator
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            // Progress bar constraints
            planProgressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            planProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            planProgressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            planProgressBar.heightAnchor.constraint(equalToConstant: 40),
            
            // Image container constraints
            imageContainerView.topAnchor.constraint(equalTo: planProgressBar.bottomAnchor, constant: 30),
            imageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            // Image view constraints
            journeyImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            journeyImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            journeyImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            journeyImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            // Participants container constraints
            participantsContainer.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 20),
            participantsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            participantsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            participantsContainer.heightAnchor.constraint(equalToConstant: 60),
            
            // Participants label constraints
            participantsLabel.centerYAnchor.constraint(equalTo: participantsContainer.centerYAnchor),
            participantsLabel.leadingAnchor.constraint(equalTo: participantsContainer.leadingAnchor, constant: 15),
            
            // Avatar stack view constraints
            avatarStackView.centerYAnchor.constraint(equalTo: participantsContainer.centerYAnchor),
            avatarStackView.leadingAnchor.constraint(equalTo: participantsLabel.trailingAnchor, constant: 10),
            avatarStackView.heightAnchor.constraint(equalToConstant: 30),
            avatarStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 90),
            
            // Invite button constraints
            inviteButton.centerYAnchor.constraint(equalTo: participantsContainer.centerYAnchor),
            inviteButton.trailingAnchor.constraint(equalTo: participantsContainer.trailingAnchor, constant: -15),
            inviteButton.widthAnchor.constraint(equalToConstant: 80),
            inviteButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Info container constraints
            infoContainerView.topAnchor.constraint(equalTo: participantsContainer.bottomAnchor, constant: 20),
            infoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            // Date row constraints
            dateRowView.topAnchor.constraint(equalTo: infoContainerView.topAnchor),
            dateRowView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            dateRowView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            dateRowView.heightAnchor.constraint(equalToConstant: 50),
            
            dateLabel.centerYAnchor.constraint(equalTo: dateRowView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateRowView.leadingAnchor, constant: 20),
            
            dateValueLabel.centerYAnchor.constraint(equalTo: dateRowView.centerYAnchor),
            dateValueLabel.trailingAnchor.constraint(equalTo: dateRowView.trailingAnchor, constant: -20),
            
            // Transport row constraints
            transportRowView.topAnchor.constraint(equalTo: dateRowView.bottomAnchor),
            transportRowView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            transportRowView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            transportRowView.heightAnchor.constraint(equalToConstant: 50),
            
            transportLabel.centerYAnchor.constraint(equalTo: transportRowView.centerYAnchor),
            transportLabel.leadingAnchor.constraint(equalTo: transportRowView.leadingAnchor, constant: 20),
            
            transportValueLabel.centerYAnchor.constraint(equalTo: transportRowView.centerYAnchor),
            transportValueLabel.trailingAnchor.constraint(equalTo: transportRowView.trailingAnchor, constant: -20),
            
            // Theme row constraints
            themeRowView.topAnchor.constraint(equalTo: transportRowView.bottomAnchor),
            themeRowView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            themeRowView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            themeRowView.heightAnchor.constraint(equalToConstant: 50),
            
            themeLabel.centerYAnchor.constraint(equalTo: themeRowView.centerYAnchor),
            themeLabel.leadingAnchor.constraint(equalTo: themeRowView.leadingAnchor, constant: 20),
            
            themeValueLabel.centerYAnchor.constraint(equalTo: themeRowView.centerYAnchor),
            themeValueLabel.trailingAnchor.constraint(equalTo: themeRowView.trailingAnchor, constant: -20),
            
            // Title text field constraints
            titleTextField.topAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Private switch constraints
            privateSwitch.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 15),
            privateSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            privateSwitchLabel.centerYAnchor.constraint(equalTo: privateSwitch.centerYAnchor),
            privateSwitchLabel.trailingAnchor.constraint(equalTo: privateSwitch.leadingAnchor, constant: -10),
            
            // Helper label constraints
            helperLabel.topAnchor.constraint(equalTo: privateSwitch.bottomAnchor, constant: 20),
            helperLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            helperLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Complete button constraints
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add separators between rows
        addSeparator(below: dateRowView)
        addSeparator(below: transportRowView)
    }
    
    private func addSeparator(below view: UIView) {
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        infoContainerView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: view.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupAvatars() {
        // 예시 아바타 추가 (사용자 자신)
        let avatarView = createAvatarView(color: .systemOrange)
        avatarStackView.addArrangedSubview(avatarView)
    }
    
    private func createAvatarView(color: UIColor) -> UIView {
        let avatarView = UIView()
        avatarView.backgroundColor = color
        avatarView.layer.cornerRadius = 15
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 30),
            avatarView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return avatarView
    }
}
