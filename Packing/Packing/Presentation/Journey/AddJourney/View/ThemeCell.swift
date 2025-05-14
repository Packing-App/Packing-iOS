//
//  ThemeCell.swift
//  Packing
//
//  Created by 이융의 on 5/7/25.
//

import UIKit

// MARK: - Theme Cell

class ThemeCell: UICollectionViewCell {
    
    // 테두리를 가진 원형 컨테이너 뷰
    private let imageContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        // 테두리 설정
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        // 원형으로 설정 - 이 시점에서는 크기가 0이므로 나중에 다시 설정됨
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        let isSmallDevice = UIScreen.main.bounds.height < 700
        label.font = UIFont.boldSystemFont(ofSize: isSmallDevice ? 10 : 12)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkmarkView: UIImageView = {
        let imageView = UIImageView()
        let isSmallDevice = UIScreen.main.bounds.height < 700
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        
        // 중요: 초기화 직후 바로 레이아웃 적용
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageContainerView.addSubview(overlayView)
        imageContainerView.addSubview(checkmarkView)
        
        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageContainerView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            imageContainerView.heightAnchor.constraint(equalTo: imageContainerView.widthAnchor), // 정사각형 보장
            
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            overlayView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            checkmarkView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.height < 700 ? 24 : 32),
            checkmarkView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height < 700 ? 24 : 32)
        ])
        
        // 중요: bounds가 변경될 때마다 원형 업데이트를 위한 옵저버 추가
        imageContainerView.layer.masksToBounds = true
        imageContainerView.addObserver(self, forKeyPath: "bounds", options: [.initial, .new], context: nil)
        overlayView.addObserver(self, forKeyPath: "bounds", options: [.initial, .new], context: nil)
    }
    
    // KVO를 통해 bounds가 변경될 때마다 cornerRadius 업데이트
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            if let view = object as? UIView {
                DispatchQueue.main.async {
                    view.layer.cornerRadius = view.bounds.width / 2
                }
            }
        }
    }
    
    // 이 메서드는 여전히 필요하지만 추가적인 안전장치로 사용
    override func layoutSubviews() {
        super.layoutSubviews()
        imageContainerView.layer.cornerRadius = imageContainerView.bounds.width / 2
        overlayView.layer.cornerRadius = overlayView.bounds.width / 2
    }
    
    func configure(with template: ThemeListModel, isSelected: Bool = false) {
        imageView.image = UIImage(named: template.image)
        titleLabel.text = template.themeName.displayName
        
        overlayView.isHidden = !isSelected
        checkmarkView.isHidden = !isSelected
        
        // 구성 후 즉시 레이아웃 적용
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        overlayView.isHidden = true
        checkmarkView.isHidden = true
    }
    
    // 메모리 누수 방지를 위한 옵저버 제거
    deinit {
        imageContainerView.removeObserver(self, forKeyPath: "bounds")
        overlayView.removeObserver(self, forKeyPath: "bounds")
    }
}
