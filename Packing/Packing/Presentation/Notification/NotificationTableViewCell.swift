//
//  NotificationTableViewCell.swift
//  Packing
//
//  Created by 이융의 on 5/1/25.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    static let identifier = "NotificationTableViewCell"
    
    // MARK: - Properties
    var notificationId: String? {
        didSet {
            // notificationId가 설정될 때마다 로그 출력
            print("🔄 Cell \(self.hashValue) notificationId changed: \(oldValue ?? "nil") -> \(notificationId ?? "nil")")
        }
    }
    var invitationCallbackHandler: ((String, Bool) -> Void)?
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let contentLabel = UILabel()
    private let unreadIndicator = UIView()
    
    let responseButtonsContainer = UIView()
    let acceptButton = UIButton(type: .system)
    let rejectButton = UIButton(type: .system)
    
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
        
        // Reset properties
        notificationId = nil
        
        // Reset button states
        acceptButton.isEnabled = true
        rejectButton.isEnabled = true
        acceptButton.alpha = 1.0
        rejectButton.alpha = 1.0
        
        // Hide response buttons by default
        responseButtonsContainer.isHidden = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        setupContainerView()
        setupUnreadIndicator()
        setupLabels()
        setupResponseButtons()
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
    
    private func setupUnreadIndicator() {
        unreadIndicator.backgroundColor = .systemBlue
        unreadIndicator.layer.cornerRadius = 4
        
        containerView.addSubview(unreadIndicator)
        unreadIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            unreadIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            unreadIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            unreadIndicator.widthAnchor.constraint(equalToConstant: 8),
            unreadIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func setupLabels() {
        // Title Label
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: unreadIndicator.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
        
        // Date Label
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .secondaryLabel
        
        containerView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        // Content Label
        contentLabel.font = UIFont.preferredFont(forTextStyle: .body)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 2
        
        containerView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    private func setupResponseButtons() {
        // Response buttons container
        responseButtonsContainer.backgroundColor = .clear
        
        containerView.addSubview(responseButtonsContainer)
        responseButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            responseButtonsContainer.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            responseButtonsContainer.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            responseButtonsContainer.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            responseButtonsContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            responseButtonsContainer.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Accept button
        acceptButton.setTitle("수락", for: .normal)
        acceptButton.tintColor = .white
        acceptButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        acceptButton.backgroundColor = .systemGreen
        acceptButton.layer.cornerRadius = 8
        acceptButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        
        responseButtonsContainer.addSubview(acceptButton)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            acceptButton.topAnchor.constraint(equalTo: responseButtonsContainer.topAnchor),
            acceptButton.leadingAnchor.constraint(equalTo: responseButtonsContainer.leadingAnchor),
            acceptButton.bottomAnchor.constraint(equalTo: responseButtonsContainer.bottomAnchor),
            acceptButton.widthAnchor.constraint(equalTo: responseButtonsContainer.widthAnchor, multiplier: 0.48)
        ])
        
        // Reject button
        rejectButton.setTitle("거절", for: .normal)
        rejectButton.tintColor = .white
        rejectButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        rejectButton.backgroundColor = .systemRed
        rejectButton.layer.cornerRadius = 8
        rejectButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        rejectButton.addTarget(self, action: #selector(rejectButtonTapped), for: .touchUpInside)
        
        responseButtonsContainer.addSubview(rejectButton)
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rejectButton.topAnchor.constraint(equalTo: responseButtonsContainer.topAnchor),
            rejectButton.trailingAnchor.constraint(equalTo: responseButtonsContainer.trailingAnchor),
            rejectButton.bottomAnchor.constraint(equalTo: responseButtonsContainer.bottomAnchor),
            rejectButton.widthAnchor.constraint(equalTo: responseButtonsContainer.widthAnchor, multiplier: 0.48)
        ])
        
        // Initially hide the response buttons
        responseButtonsContainer.isHidden = true
    }
    
    // MARK: - Button Actions
    @objc private func acceptButtonTapped() {
        guard let id = notificationId, !id.isEmpty else {
            print("Error: No notification ID available")
            return
        }
        
        print("Accept button tapped - ID: \(id)")
        invitationCallbackHandler?(id, true)
    }
    
    @objc private func rejectButtonTapped() {
        guard let id = notificationId, !id.isEmpty else {
            print("Error: No notification ID available")
            return
        }
        
        print("Reject button tapped - ID: \(id)")
        invitationCallbackHandler?(id, false)
    }
    
    // MARK: - Configure Cell
    func configure(with notification: NotificationModel) {
        // Store notification ID - 중요: 옵셔널 언래핑 확인
        if let id = notification.id {
            self.notificationId = id
            print("⭐️ Cell configured with ID: \(id)")
        } else {
            print("⚠️ Warning: Notification has no ID!")
            self.notificationId = nil
        }
        
        // Set notification type as title
        switch notification.type {
        case .invitation:
            titleLabel.text = "초대장"
            responseButtonsContainer.isHidden = false
            print("Configuring invitation cell, ID: \(notification.id ?? "unknown"), showing buttons")
        case .weather:
            titleLabel.text = "날씨 알림"
            responseButtonsContainer.isHidden = true
        case .reminder:
            titleLabel.text = "리마인더"
            responseButtonsContainer.isHidden = true
        }
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateLabel.text = dateFormatter.string(from: notification.createdAt)
        
        // Set content
        contentLabel.text = notification.content
        
        // Update unread indicator
        unreadIndicator.isHidden = notification.isRead
    }
}
