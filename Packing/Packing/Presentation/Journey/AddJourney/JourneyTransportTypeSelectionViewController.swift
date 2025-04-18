//
//  JourneyTransportTypeSelectionViewController.swift
//  Packing
//
//  Created by 이융의 on 4/14/25.
//

import UIKit

class JourneyTransportTypeSelectionViewController: UIViewController {
    
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
    
    private var selectedTransportOption: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTransportOptions()
        setupActions()
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
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(transportOptionTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        return containerView
    }
    
    private func setupActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func transportOptionTapped(_ sender: UITapGestureRecognizer) {
        if let selectedView = sender.view {
            // Reset all options
            for case let optionView as UIView in transportStackView.arrangedSubviews {
                optionView.backgroundColor = .white
                optionView.layer.borderColor = UIColor.systemGray5.cgColor
                
                if let iconView = optionView.viewWithTag(1001) as? UIImageView {
                    iconView.tintColor = UIColor.systemBlue
                }
                
                if let titleLabel = optionView.viewWithTag(1002) as? UILabel {
                    titleLabel.textColor = .black
                }
            }
            
            // Highlight selected option
            selectedView.backgroundColor = UIColor.main
            selectedView.layer.borderColor = UIColor.main.cgColor
            
            if let iconView = selectedView.viewWithTag(1001) as? UIImageView {
                iconView.tintColor = .white
            }
            
            if let titleLabel = selectedView.viewWithTag(1002) as? UILabel {
                titleLabel.textColor = .white
            }
            
            // Store selected option and enable next button
            selectedTransportOption = selectedView
            enableNextButton()
        }
    }
    
    private func enableNextButton() {
        if selectedTransportOption != nil {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .black
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .lightGray
        }
    }
    
    @objc private func nextButtonTapped() {
        let travelDateSelectionViewController = JourneyDateSelectionViewController()
        navigationController?.pushViewController(travelDateSelectionViewController, animated: true)
    }
    
    @objc private func skipButtonTapped() {
        // Handle skip button action
        print("Skip button tapped")
    }
}
