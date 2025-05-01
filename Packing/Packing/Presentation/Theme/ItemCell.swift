//
//  ItemCell.swift
//  Packing
//
//  Created by 이융의 on 4/26/25.
//

import UIKit

class ItemCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.systemGray4.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let essentialIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let essentialBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let essentialLabel: UILabel = {
        let label = UILabel()
        label.text = "필수"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionCheckmark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .main
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // 셀 배경색 설정
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        // 컨테이너 뷰 추가
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(selectionCheckmark)
        
        // 필수 배지 설정
        essentialBadge.addSubview(essentialLabel)
        
        // 스택뷰에 컴포넌트 추가
        stackView.addArrangedSubview(essentialIndicator)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(essentialBadge)
        
        // 스택뷰에 Spacer 역할을 할 빈 뷰 추가
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(spacerView)
        
        NSLayoutConstraint.activate([
            // 컨테이너 뷰 제약조건
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // 스택뷰 제약조건
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),
            
            // 필수 표시 아이콘 제약조건
            essentialIndicator.widthAnchor.constraint(equalToConstant: 8),
            essentialIndicator.heightAnchor.constraint(equalToConstant: 8),
            
            // 필수 배지 제약조건
            essentialBadge.heightAnchor.constraint(equalToConstant: 22),
            essentialLabel.leadingAnchor.constraint(equalTo: essentialBadge.leadingAnchor, constant: 8),
            essentialLabel.trailingAnchor.constraint(equalTo: essentialBadge.trailingAnchor, constant: -8),
            essentialLabel.centerYAnchor.constraint(equalTo: essentialBadge.centerYAnchor),
            
            // 체크마크 제약조건
            selectionCheckmark.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            selectionCheckmark.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            selectionCheckmark.widthAnchor.constraint(equalToConstant: 24),
            selectionCheckmark.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with item: RecommendedItem) {
        nameLabel.text = item.name
        
        // 필수 아이템 표시 방식 개선
        if item.isEssential {
            essentialIndicator.isHidden = false
            essentialBadge.isHidden = false
        } else {
            essentialIndicator.isHidden = true
            essentialBadge.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // 선택 상태에 따라 체크마크 표시/숨김 및 컨테이너 스타일 변경
        selectionCheckmark.isHidden = !selected
        
        if selected {
            containerView.layer.borderWidth = 1.5
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        } else {
            containerView.layer.borderWidth = 0
            containerView.backgroundColor = .systemBackground
        }
        
        // 선택 시 기본 배경색 변경 방지 및 체크마크 숨김
        self.selectedBackgroundView = UIView()
        self.accessoryType = .none // 셀 기본 체크마크를 제거
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            UIView.animate(withDuration: 0.1) {
                // 크기 변화 애니메이션 제거하고 배경색만 변경
                // self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                self.containerView.backgroundColor = .systemGray6
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                // self.containerView.transform = CGAffineTransform.identity
                self.containerView.backgroundColor = self.isSelected ? UIColor.main.withAlphaComponent(0.05) : .systemBackground
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        essentialIndicator.isHidden = true
        essentialBadge.isHidden = true
        selectionCheckmark.isHidden = true
        containerView.layer.borderWidth = 0
        containerView.backgroundColor = .systemBackground
        // 쓰이지 않는 transform 리셋 제거
        // containerView.transform = CGAffineTransform.identity
        self.accessoryType = .none // 기본 체크마크 제거 확실히
    }
}
