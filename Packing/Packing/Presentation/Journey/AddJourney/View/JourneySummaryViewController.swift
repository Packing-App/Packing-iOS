//
//  JourneySummaryViewController.swift
//  Packing
//
//  Created by 이융의 on 4/17/25.
//

import UIKit

class JourneySummaryViewController: UIViewController {
    
    // MARK: - Properties
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
        imageView.image = UIImage(named: "waterfall") // 예시 이미지
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
        label.text = "파티원 4명"
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
        label.text = "2023.12.01 - 12.07"
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
        label.text = "자전거 타기"
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
        label.text = "크로아티아, 플리트비체"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .right
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAvatars()
        setupActions()
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
        
        // Add helper label
        view.addSubview(helperLabel)
        
        // Add complete button
        view.addSubview(completeButton)
        
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
            imageContainerView.heightAnchor.constraint(equalToConstant: 200),
            
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
            
            // Helper label constraints
            helperLabel.topAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: 30),
            helperLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            helperLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Complete button constraints
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 50)
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
        // Sample colors for avatars
        let colors: [UIColor] = [.systemOrange, .systemRed, .systemGray, .systemBlue]
        
        for i in 0..<3 {
            let avatarView = createAvatarView(color: colors[i])
            avatarStackView.addArrangedSubview(avatarView)
        }
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
    
    private func setupActions() {
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        inviteButton.addTarget(self, action: #selector(inviteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func completeButtonTapped() {
        // Handle complete button action
        print("Complete button tapped")
    }
    
    @objc private func inviteButtonTapped() {
        // Handle invite button action
        print("Invite button tapped")
    }
}
