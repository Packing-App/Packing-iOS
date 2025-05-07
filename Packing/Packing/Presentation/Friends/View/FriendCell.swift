//
//  FriendCell.swift
//  Packing
//
//  Created by 이융의 on 4/30/25.
//

import UIKit
import RxSwift
import Kingfisher

// MARK: - FriendCell

class FriendCell: UITableViewCell {
    static let identifier = "FriendCell"
    
    var disposeBag = DisposeBag()
    
    // UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let inviteButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "초대하기"
        configuration.baseBackgroundColor = .main
        configuration.baseForegroundColor = .white
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            return outgoing
        }
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12)
        
        let button = UIButton(configuration: configuration)
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.titleLabel?.numberOfLines = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Store constraints that need to be activated/deactivated
    private var introConstraints: [NSLayoutConstraint] = []
    private var noIntroConstraints: [NSLayoutConstraint] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        profileImageView.image = nil
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.containerView.backgroundColor = highlighted ? .systemGray6 : .systemBackground
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        // Add containerView first
        contentView.addSubview(containerView)
        
        // Add subviews to containerView
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(emailLabel)
        containerView.addSubview(introLabel)
        containerView.addSubview(inviteButton)
        
        // Basic constraints that are always active
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // Profile image
            profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),
            profileImageView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 10),
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: inviteButton.leadingAnchor, constant: -8),
            
            // Email label
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: inviteButton.leadingAnchor, constant: -8),
            
            // Invite button
            inviteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            inviteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            // 버튼 너비를 고정된 값으로 설정
            inviteButton.widthAnchor.constraint(equalToConstant: 80) // 원하는 너비로 조정하세요
        ])
        
        // Constraints for when intro is visible
        introConstraints = [
            introLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 2),
            introLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            introLabel.trailingAnchor.constraint(equalTo: inviteButton.leadingAnchor, constant: -8),
            introLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ]
        
        // Constraints for when intro is hidden
        noIntroConstraints = [
            emailLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ]
        
        // By default, assume intro is hidden
        NSLayoutConstraint.activate(noIntroConstraints)
    }
    
    func configure(with friend: Friend) {
        nameLabel.text = friend.name
        emailLabel.text = friend.email
        
        // Handle constraints based on whether intro is available
        if let intro = friend.intro, !intro.isEmpty {
            introLabel.text = intro
            introLabel.isHidden = false
            
            // Update constraints
            NSLayoutConstraint.deactivate(noIntroConstraints)
            NSLayoutConstraint.activate(introConstraints)
        } else {
            introLabel.isHidden = true
            
            // Update constraints
            NSLayoutConstraint.deactivate(introConstraints)
            NSLayoutConstraint.activate(noIntroConstraints)
        }
        
        // 프로필 이미지 로드
        if let profileImageUrlString = friend.profileImage, let url = URL(string: profileImageUrlString) {
            profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .systemGray
        }
    }
}
