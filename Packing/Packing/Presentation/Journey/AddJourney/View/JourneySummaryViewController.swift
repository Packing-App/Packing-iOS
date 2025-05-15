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
    
    // Use computed property for isSmallDevice check
    private var isSmallDevice: Bool {
        return UIScreen.main.bounds.height < 700
    }
    
    private lazy var navigationTitleLabel: UILabel = {
        let label = UILabel()
        let attachmentString = NSMutableAttributedString(string: "")
        let imageAttachment: NSTextAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "logoIconWhite")
        let iconSize: CGFloat = isSmallDevice ? 20 : 24
        imageAttachment.bounds = CGRect(x: 0, y: -6, width: iconSize, height: iconSize)
        attachmentString.append(NSAttributedString(attachment: imageAttachment))
        attachmentString.append(NSAttributedString(string: " 패킹"))
        label.attributedText = attachmentString
        label.sizeToFit()
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: isSmallDevice ? 18 : 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let planProgressBar: PlanProgressBar = {
        let progressBar = PlanProgressBar(progress: 3)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let summaryContainerView: UIView = {
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
    
    private let journeyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "나의 여행"
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 20 : 24, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let destinationInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "제주도 • 2025.05.10 - 2025.05.15"
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 14 : 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let themeIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "airplane")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .main
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "해외여행"
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 14 : 16, weight: .medium)
        label.textColor = .main
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 14 : 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateValueLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜 미설정"
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 14 : 16)
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
        label.text = "이동 수단"
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 14 : 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let transportValueLabel: UILabel = {
        let label = UILabel()
        label.text = "미설정"
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 14 : 16)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let destinationRowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let destinationLabel: UILabel = {
        let label = UILabel()
        label.text = "여행 목적지"
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 14 : 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let destinationValueLabel: UILabel = {
        let label = UILabel()
        label.text = "미설정"
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 14 : 16)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "여행 제목을 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 14 : 16)
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
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 12 : 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let helperLabel: UILabel = {
        let label = UILabel()
        label.text = "위 정보가 맞으면 완료 버튼을 눌러주세요"
        label.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 12 : 14)
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
        button.titleLabel?.font = .systemFont(ofSize: UIScreen.main.bounds.height < 700 ? 15 : 16, weight: .medium)
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
        
        // 로그인 상태 변경 알림 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginStatusChanged),
            name: NSNotification.Name("UserLoginStatusChanged"),
            object: nil
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.viewDidAppear)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 로그인 상태 변경 처리 메서드 추가
    @objc private func handleLoginStatusChanged() {
        // 로그인 상태가 변경되면 reactor에 로그인 상태 체크 액션 전송
        reactor?.action.onNext(.checkLoginStatus)
        
        // 로그인 후 여행 정보가 유지되는지 확인 (디버깅용)
        if let journeyModel = (reactor?.coordinator as? JourneyCreationCoordinator)?.getJourneyModel() {
            print("로그인 후 여행 정보 확인:")
            print("- 출발지: \(journeyModel.origin)")
            print("- 도착지: \(journeyModel.destination)")
            print("- 테마: \(String(describing: journeyModel.themes.first?.displayName))")
            print("- 출발일: \(String(describing: journeyModel.startDate))")
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        
        // State
        
        reactor.state.map { $0.requireLogin }
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showLoginRequiredAlert()
            })
            .disposed(by: disposeBag)
        
        // 여행 모델 정보 표시
        reactor.state.map { $0.transportTypeText }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.transportValueLabel.text = text
                // 요약 화면의 테마 정보와 아이콘 업데이트
                if text != "미설정" {
                    self?.themeLabel.text = text
                    
                    // 운송 수단에 따라 아이콘 업데이트
                    switch text {
                    case "비행기":
                        self?.themeIconView.image = UIImage(systemName: "airplane")
                    case "기차":
                        self?.themeIconView.image = UIImage(systemName: "tram")
                    case "배":
                        self?.themeIconView.image = UIImage(systemName: "ferry")
                    case "버스":
                        self?.themeIconView.image = UIImage(systemName: "bus")
                    case "도보":
                        self?.themeIconView.image = UIImage(systemName: "figure.walk")
                    case "기타":
                        self?.themeIconView.image = UIImage(systemName: "backpack")
                    default:
                        self?.themeIconView.image = UIImage(systemName: "map")
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.destinationText }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: destinationValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.destinationText }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                // 요약 화면의 목적지 정보도 업데이트
                if text != "미설정" {
                    var infoText = text
                    if let dateText = self?.dateValueLabel.text, dateText != "날짜 미설정" {
                        infoText += " • " + dateText
                    }
                    self?.destinationInfoLabel.text = infoText
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.dateRangeText }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.dateValueLabel.text = text
                
                // 요약 화면의 날짜 정보도 업데이트
                if text != "날짜 미설정" {
                    var infoText = text
                    if let destText = self?.destinationValueLabel.text, destText != "미설정" {
                        infoText = destText + " • " + text
                    }
                    self?.destinationInfoLabel.text = infoText
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.title }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] title in
                self?.titleTextField.text = title
                if !title.isEmpty {
                    self?.journeyTitleLabel.text = title
                }
            })
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
    
    private func showLoginRequiredAlert() {
        let alert = UIAlertController(
            title: "로그인 필요",
            message: "여행 정보를 저장하고 추천 아이템을 확인하려면 로그인이 필요합니다. 로그인하면 지금까지 입력한 여행 정보가 유지됩니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "로그인", style: .default) { [weak self] _ in
            self?.navigateToLogin()
        })
        
        present(alert, animated: true)
    }
    
    private func navigateToLogin() {
        guard let navigationController = self.navigationController else { return }
        AuthCoordinator.shared.navigateToLogin(isFromJourneyCreation: true, journeyNavigation: navigationController)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationTitleLabel)
        
        view.backgroundColor = .systemGray6
        
        // Add progress bar
        view.addSubview(planProgressBar)
        
        // Add summary container
        view.addSubview(summaryContainerView)
        summaryContainerView.addSubview(journeyTitleLabel)
        summaryContainerView.addSubview(destinationInfoLabel)
        summaryContainerView.addSubview(themeIconView)
        summaryContainerView.addSubview(themeLabel)
        
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
        
        // Add destination row
        infoContainerView.addSubview(destinationRowView)
        destinationRowView.addSubview(destinationLabel)
        destinationRowView.addSubview(destinationValueLabel)
        
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
        
        // Calculate dimensions based on device size
        let summaryHeight: CGFloat = isSmallDevice ? 180 : 220
        let infoContainerHeight: CGFloat = isSmallDevice ? 120 : 150
        let rowHeight: CGFloat = isSmallDevice ? 40 : 50
        
        NSLayoutConstraint.activate([
            // Progress bar constraints - Match previous views
            planProgressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            planProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            planProgressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            planProgressBar.heightAnchor.constraint(equalToConstant: isSmallDevice ? 15 : 20),
            
            // Summary container constraints
            summaryContainerView.topAnchor.constraint(equalTo: planProgressBar.bottomAnchor, constant: 30),
            summaryContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            summaryContainerView.heightAnchor.constraint(equalToConstant: summaryHeight),
            
            // Journey title constraints
            journeyTitleLabel.topAnchor.constraint(equalTo: summaryContainerView.topAnchor, constant: isSmallDevice ? 25 : 35),
            journeyTitleLabel.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 20),
            journeyTitleLabel.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -20),
            
            // Destination info constraints
            destinationInfoLabel.topAnchor.constraint(equalTo: journeyTitleLabel.bottomAnchor, constant: isSmallDevice ? 8 : 10),
            destinationInfoLabel.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 20),
            destinationInfoLabel.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -20),
            
            // Theme icon constraints
            themeIconView.topAnchor.constraint(equalTo: destinationInfoLabel.bottomAnchor, constant: isSmallDevice ? 20 : 30),
            themeIconView.centerXAnchor.constraint(equalTo: summaryContainerView.centerXAnchor),
            themeIconView.widthAnchor.constraint(equalToConstant: isSmallDevice ? 30 : 36),
            themeIconView.heightAnchor.constraint(equalToConstant: isSmallDevice ? 30 : 36),
            
            // Theme label constraints
            themeLabel.topAnchor.constraint(equalTo: themeIconView.bottomAnchor, constant: 8),
            themeLabel.centerXAnchor.constraint(equalTo: summaryContainerView.centerXAnchor),
            
            // Info container constraints
            infoContainerView.topAnchor.constraint(equalTo: summaryContainerView.bottomAnchor, constant: isSmallDevice ? 15 : 20),
            infoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoContainerView.heightAnchor.constraint(equalToConstant: infoContainerHeight),
            
            // Date row constraints
            dateRowView.topAnchor.constraint(equalTo: infoContainerView.topAnchor),
            dateRowView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            dateRowView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            dateRowView.heightAnchor.constraint(equalToConstant: rowHeight),
            
            dateLabel.centerYAnchor.constraint(equalTo: dateRowView.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateRowView.leadingAnchor, constant: 20),
            
            dateValueLabel.centerYAnchor.constraint(equalTo: dateRowView.centerYAnchor),
            dateValueLabel.trailingAnchor.constraint(equalTo: dateRowView.trailingAnchor, constant: -20),
            
            // Transport row constraints
            transportRowView.topAnchor.constraint(equalTo: dateRowView.bottomAnchor),
            transportRowView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            transportRowView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            transportRowView.heightAnchor.constraint(equalToConstant: rowHeight),
            
            transportLabel.centerYAnchor.constraint(equalTo: transportRowView.centerYAnchor),
            transportLabel.leadingAnchor.constraint(equalTo: transportRowView.leadingAnchor, constant: 20),
            
            transportValueLabel.centerYAnchor.constraint(equalTo: transportRowView.centerYAnchor),
            transportValueLabel.trailingAnchor.constraint(equalTo: transportRowView.trailingAnchor, constant: -20),
            
            // Destination row constraints
            destinationRowView.topAnchor.constraint(equalTo: transportRowView.bottomAnchor),
            destinationRowView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            destinationRowView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            destinationRowView.heightAnchor.constraint(equalToConstant: rowHeight),
            
            destinationLabel.centerYAnchor.constraint(equalTo: destinationRowView.centerYAnchor),
            destinationLabel.leadingAnchor.constraint(equalTo: destinationRowView.leadingAnchor, constant: 20),
            
            destinationValueLabel.centerYAnchor.constraint(equalTo: destinationRowView.centerYAnchor),
            destinationValueLabel.trailingAnchor.constraint(equalTo: destinationRowView.trailingAnchor, constant: -20),
            
            // Title text field constraints
            titleTextField.topAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: isSmallDevice ? 15 : 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: isSmallDevice ? 35 : 40),
            
            // Private switch constraints
            privateSwitch.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: isSmallDevice ? 10 : 15),
            privateSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            privateSwitchLabel.centerYAnchor.constraint(equalTo: privateSwitch.centerYAnchor),
            privateSwitchLabel.trailingAnchor.constraint(equalTo: privateSwitch.leadingAnchor, constant: -10),
            
            // Helper label constraints
            helperLabel.topAnchor.constraint(equalTo: privateSwitch.bottomAnchor, constant: isSmallDevice ? 15 : 20),
            helperLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            helperLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Complete button constraints
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: isSmallDevice ? 45 : 50),
            
            // Loading indicator constraints
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add separators between rows
        addSeparator(below: dateRowView)
        addSeparator(below: transportRowView)
        
        // Apply transform for smaller switch on small devices
        if isSmallDevice {
            privateSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
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
}
