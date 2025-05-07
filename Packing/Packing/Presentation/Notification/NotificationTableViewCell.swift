//
//  NotificationTableViewCell.swift
//  Packing
//
//  Created by 이융의 on 4/30/25.
//

import UIKit

// MARK: - NotificationTableViewCell
class NotificationTableViewCell: UITableViewCell {
    static let identifier = "NotificationTableViewCell"
    
    // UI Components
    private let cardView = UIView()
    private let mainStackView = UIStackView()
    private let headerStack = UIStackView()
    private let typeContainer = UIView()
    private let typeIconView = UIImageView()
    private let typeLabel = UILabel()
    private let dateLabel = UILabel()
    private let contentLabel = UILabel()
    private let actionContainer = UIView()
    
    // Response buttons for invitation
    private let buttonStack = UIStackView()
    let acceptButton = UIButton(type: .system)
    let rejectButton = UIButton(type: .system)
    
    // Badge for unread indicator
    private let unreadBadge = UIView()
    
    // notificationId 저장을 위한 속성
    var notificationId: String?
    var invitationCallbackDelegate: InvitationCallbackDelegate?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // ID 리셋
        notificationId = nil
        
        // Reset states
        acceptButton.isEnabled = true
        rejectButton.isEnabled = true
        acceptButton.alpha = 1.0
        rejectButton.alpha = 1.0
        
        // Hide action container by default
        actionContainer.isHidden = true
        
        // Reset visual states
        cardView.alpha = 1.0
        unreadBadge.isHidden = true
        
        // Reset shadow animation
        cardView.layer.shadowOpacity = 0.1
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupCardView()
        setupMainStackView()
        setupHeaderStackView()
        setupTypeContainer()
        setupContentLabel()
        setupActionContainer()
        setupUnreadBadge()
    }
    
    private func setupCardView() {
        // Modern card style with subtle shadow and rounded corners
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = false
        
        // Elegant shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupMainStackView() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 12
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        
        cardView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: cardView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }
    
    private func setupHeaderStackView() {
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center
        headerStack.distribution = .equalSpacing
        
        // Date label setup
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .tertiaryLabel
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        headerStack.addArrangedSubview(typeContainer)
        headerStack.addArrangedSubview(dateLabel)
        
        mainStackView.addArrangedSubview(headerStack)
    }
    
    private func setupTypeContainer() {
        typeContainer.backgroundColor = .secondarySystemFill
        typeContainer.layer.cornerRadius = 10
        
        // Type icon setup
        typeIconView.contentMode = .scaleAspectFit
        typeIconView.tintColor = .secondaryLabel
        
        // Type label setup
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        typeLabel.textColor = .secondaryLabel
        
        // Add to type container
        typeContainer.addSubview(typeIconView)
        typeContainer.addSubview(typeLabel)
        
        typeIconView.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            typeIconView.leadingAnchor.constraint(equalTo: typeContainer.leadingAnchor, constant: 8),
            typeIconView.centerYAnchor.constraint(equalTo: typeContainer.centerYAnchor),
            typeIconView.widthAnchor.constraint(equalToConstant: 12),
            typeIconView.heightAnchor.constraint(equalToConstant: 12),
            
            typeLabel.leadingAnchor.constraint(equalTo: typeIconView.trailingAnchor, constant: 4),
            typeLabel.trailingAnchor.constraint(equalTo: typeContainer.trailingAnchor, constant: -8),
            typeLabel.centerYAnchor.constraint(equalTo: typeContainer.centerYAnchor),
            
            typeContainer.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setupContentLabel() {
        contentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        mainStackView.addArrangedSubview(contentLabel)
    }
    
    private func setupActionContainer() {
        actionContainer.backgroundColor = .clear
        mainStackView.addArrangedSubview(actionContainer)
        
        // Modern button stack
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .fill
        
        actionContainer.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: actionContainer.topAnchor, constant: 8),
            buttonStack.leadingAnchor.constraint(equalTo: actionContainer.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: actionContainer.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: actionContainer.bottomAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Setup elegant buttons
        setupAcceptButton()
        setupRejectButton()
        
        // Add buttons to stack
        buttonStack.addArrangedSubview(acceptButton)
        buttonStack.addArrangedSubview(rejectButton)
        
        // Initially hide the action container
        actionContainer.isHidden = true
    }
    
    private func setupAcceptButton() {
        configureButton(
            acceptButton,
            title: "수락",
            icon: "checkmark",
            backgroundColor: UIColor.systemGreen.withAlphaComponent(0.1),
            textColor: .systemGreen
        )
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
    }
    
    private func setupRejectButton() {
        configureButton(
            rejectButton,
            title: "거절",
            icon: "xmark",
            backgroundColor: UIColor.systemRed.withAlphaComponent(0.1),
            textColor: .systemRed
        )
        rejectButton.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
    }
    
    private func configureButton(_ button: UIButton, title: String, icon: String, backgroundColor: UIColor, textColor: UIColor) {
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.tintColor = textColor
        button.setTitleColor(textColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 12
        
        // Modern layout for button content
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        // Set font
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    private func setupUnreadBadge() {
        unreadBadge.backgroundColor = .main
        unreadBadge.layer.cornerRadius = 3
        unreadBadge.isHidden = true
        
        cardView.addSubview(unreadBadge)
        unreadBadge.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            unreadBadge.widthAnchor.constraint(equalToConstant: 6),
            unreadBadge.heightAnchor.constraint(equalToConstant: 6),
            unreadBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            unreadBadge.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16)
        ])
    }
    
    @objc private func acceptButtonTapped() {
        animateButtonTap(acceptButton)
        
        // 델리게이트를 통해 처리
        if let id = notificationId {
            invitationCallbackDelegate?.handleInvitationResponse(notificationId: id, accept: true)
        }
    }
    
    @objc private func rejectButtonTapped() {
        animateButtonTap(rejectButton)
        
        // 델리게이트를 통해 처리
        if let id = notificationId {
            invitationCallbackDelegate?.handleInvitationResponse(notificationId: id, accept: false)
        }
    }
    
    private func animateButtonTap(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = CGAffineTransform.identity
            }
        })
    }
    
    // MARK: - Configuration
    func configure(with notification: NotificationModel) {
        // 알림 ID 저장
        self.notificationId = notification.id
        
        // 콘텐츠 설정
        contentLabel.text = notification.content
        
        // 타입에 따른 아이콘 및 레이블 설정
        configureForType(notification.type)
        
        // 날짜 포맷팅
        configureDateLabel(notification.createdAt)
        
        // 읽음 상태에 따른 시각적 처리
        configureReadState(notification.isRead)
        
        // 초대 알림인 경우 응답 버튼 처리
        configureResponseButtons(notification)
    }
    
    private func configureForType(_ type: NotificationType) {
        switch type {
        case .friendRequest:
            typeIconView.image = UIImage(systemName: "person.badge.plus")
            typeLabel.text = "친구 요청"
        case .friendRequestResponse:
            typeIconView.image = UIImage(systemName: "person.badge.shield.checkmark")
            typeLabel.text = "친구 요청 수락"

        case .weather:
            typeIconView.image = UIImage(systemName: "cloud.sun")
            typeLabel.text = "날씨"
        case .reminder:
            typeIconView.image = UIImage(systemName: "bell")
            typeLabel.text = "리마인더"
            
        case .invitation:
            typeIconView.image = UIImage(systemName: "envelope")
            typeLabel.text = "초대"
        case .journeyInvitationResponse:
            typeIconView.image = UIImage(systemName: "envelope.badge.person.crop")
        }
    }
    
    private func configureDateLabel(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.doesRelativeDateFormatting = true
        
        // 오늘이면 시간만, 아니면 날짜+시간
        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
        } else {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
        }
        
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    private func configureReadState(_ isRead: Bool) {
        if isRead {
            // 읽은 알림은 약간 투명하게 처리
            cardView.alpha = 0.7
            cardView.backgroundColor = .secondarySystemBackground
            unreadBadge.isHidden = true
            cardView.layer.shadowOpacity = 0.05
        } else {
            // 안 읽은 알림은 강조
            cardView.alpha = 1.0
            cardView.backgroundColor = .systemBackground
            unreadBadge.isHidden = false
            cardView.layer.shadowOpacity = 0.1
        }
    }
    
    private func configureResponseButtons(_ notification: NotificationModel) {
        // 초대 알림이고 읽지 않은 상태인 경우에만 응답 버튼 표시
        let shouldShowButtons = notification.type == .invitation && !notification.isRead
        actionContainer.isHidden = !shouldShowButtons
        
        if notification.isRead && notification.type == .invitation {
            // 이미 응답한 알림의 경우 버튼 비활성화
            acceptButton.isEnabled = false
            rejectButton.isEnabled = false
            acceptButton.alpha = 0.5
            rejectButton.alpha = 0.5
        } else {
            // 응답하지 않은 알림의 경우 버튼 활성화
            acceptButton.isEnabled = true
            rejectButton.isEnabled = true
            acceptButton.alpha = 1.0
            rejectButton.alpha = 1.0
        }
    }
}

// MARK: - InvitationCallbackDelegate 프로토콜
// ViewController가 구현할 프로토콜
protocol InvitationCallbackDelegate: AnyObject {
    func handleInvitationResponse(notificationId: String, accept: Bool)
}
