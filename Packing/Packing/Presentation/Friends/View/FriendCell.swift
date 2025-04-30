//
//  FriendCell.swift
//  Packing
//
//  Created by 이융의 on 4/30/25.
//

import UIKit
import RxSwift

// MARK: - FriendCell

class FriendCell: UITableViewCell {
    static let identifier = "FriendCell"
    
    var disposeBag = DisposeBag()
    
    // UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let inviteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("초대하기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
    
    private func setupUI() {
        // Add subviews
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(introLabel)
        contentView.addSubview(inviteButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            profileImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: inviteButton.leadingAnchor, constant: -12),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            introLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            introLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            introLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            introLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            inviteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            inviteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            inviteButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            inviteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with friend: Friend) {
        nameLabel.text = friend.name
        emailLabel.text = friend.email
        introLabel.text = friend.intro ?? "자기소개가 없습니다."
        
        // 프로필 이미지 로드 (실제 구현에서는 이미지 라이브러리 사용)
        if let profileImageUrlString = friend.profileImage, let url = URL(string: profileImageUrlString) {
            // 실제 구현에서는 Kingfisher, SDWebImage 등의 라이브러리를 사용해 이미지 로드
            // 예: profileImageView.kf.setImage(with: url)
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .gray
        }
    }
}
