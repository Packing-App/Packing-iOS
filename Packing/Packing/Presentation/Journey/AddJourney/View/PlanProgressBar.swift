//
//  PlanProgressBar.swift
//  Packing
//
//  Created by 이융의 on 4/13/25.
//

import UIKit

class PlanProgressBar: UIView {
    
    var progress: Int {
        didSet {
            updateUI()
        }
    }
    
    let progressGray = UIColor(hexCode: "C6C6C6")
    let progressBlue = UIColor.main
    let progressDeactivateGray = UIColor(hexCode: "717171")
    
    init(progress: Int) {
        self.progress = progress
        super.init(frame: .zero)
        setupUI()
        updateUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var progressLine: UIProgressView = {
        let progressLine = UIProgressView()
        progressLine.trackTintColor = progressGray
        progressLine.progressTintColor = progressBlue
        progressLine.setProgress(Float(progress) / 3.0, animated: false)
        progressLine.translatesAutoresizingMaskIntoConstraints = false
        return progressLine
    }()
    
    private lazy var transportIcon: UIImageView = {
        let transportIcon = UIImageView(image: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal))
        transportIcon.clipsToBounds = true
        transportIcon.layer.cornerRadius = 10
        transportIcon.translatesAutoresizingMaskIntoConstraints = false
        return transportIcon
    }()
    
    private lazy var infoIcon: UIImageView = {
        let infoIcon = UIImageView(image: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal))
        infoIcon.clipsToBounds = true
        infoIcon.layer.cornerRadius = 10
        infoIcon.translatesAutoresizingMaskIntoConstraints = false
        return infoIcon
    }()
    
    private lazy var themeIcon: UIImageView = {
        let themeIcon = UIImageView(image: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal))
        themeIcon.clipsToBounds = true
        themeIcon.layer.cornerRadius = 10
        themeIcon.translatesAutoresizingMaskIntoConstraints = false
        return themeIcon
    }()
    
    private lazy var completeIcon: UIImageView = {
        let completeIcon = UIImageView(image: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal))
        completeIcon.clipsToBounds = true
        completeIcon.layer.cornerRadius = 10
        completeIcon.translatesAutoresizingMaskIntoConstraints = false
        return completeIcon
    }()
    
    private lazy var transportText: UILabel = {
        let transportText = UILabel()
        transportText.text = "이동수단".localized
        transportText.font = UIFont.systemFont(ofSize: 10)
        transportText.addCharacterSpacing(-0.025)
        transportText.translatesAutoresizingMaskIntoConstraints = false
        return transportText
    }()
    
    private lazy var infoText: UILabel = {
        let infoText = UILabel()
        infoText.text = "여행정보".localized
        infoText.font = UIFont.systemFont(ofSize: 10)
        infoText.addCharacterSpacing(-0.025)
        infoText.translatesAutoresizingMaskIntoConstraints = false
        return infoText
    }()
    
    private lazy var themeText: UILabel = {
        let themeText = UILabel()
        themeText.text = "여행테마".localized
        themeText.font = UIFont.systemFont(ofSize: 10)
        themeText.addCharacterSpacing(-0.025)
        themeText.translatesAutoresizingMaskIntoConstraints = false
        return themeText
    }()
    
    private lazy var completeText: UILabel = {
        let completeText = UILabel()
        completeText.text = "완료".localized
        completeText.font = UIFont.systemFont(ofSize: 10)
        completeText.addCharacterSpacing(-0.025)
        completeText.translatesAutoresizingMaskIntoConstraints = false
        return completeText
    }()
    
    private func setupUI() {
        // 뷰 계층 구조 추가
        addSubview(progressLine)
        addSubview(transportIcon)
        addSubview(infoIcon)
        addSubview(themeIcon)
        addSubview(completeIcon)
        addSubview(transportText)
        addSubview(infoText)
        addSubview(themeText)
        addSubview(completeText)
        
        // 스택 뷰를 사용하여 아이콘 균등 배치 문제 해결
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 60
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 스택 뷰에 아이콘 추가
        stackView.addArrangedSubview(transportIcon)
        stackView.addArrangedSubview(infoIcon)
        stackView.addArrangedSubview(themeIcon)
        stackView.addArrangedSubview(completeIcon)
        
        addSubview(stackView)
        
        // 레이아웃 설정
        NSLayoutConstraint.activate([
            // 스택 뷰 레이아웃
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // 프로그레스 라인 레이아웃
            progressLine.heightAnchor.constraint(equalToConstant: 1),
            progressLine.leadingAnchor.constraint(equalTo: transportIcon.centerXAnchor, constant: 8),
            progressLine.trailingAnchor.constraint(equalTo: completeIcon.centerXAnchor, constant: -8),
            progressLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // 아이콘 크기 설정
            transportIcon.heightAnchor.constraint(equalToConstant: 20),
            transportIcon.widthAnchor.constraint(equalToConstant: 20),
            
            infoIcon.heightAnchor.constraint(equalToConstant: 20),
            infoIcon.widthAnchor.constraint(equalToConstant: 20),
            
            themeIcon.heightAnchor.constraint(equalToConstant: 20),
            themeIcon.widthAnchor.constraint(equalToConstant: 20),
            
            completeIcon.heightAnchor.constraint(equalToConstant: 20),
            completeIcon.widthAnchor.constraint(equalToConstant: 20),
            
            // 텍스트 레이아웃
            transportText.centerXAnchor.constraint(equalTo: transportIcon.centerXAnchor),
            transportText.topAnchor.constraint(equalTo: transportIcon.bottomAnchor, constant: 5),
            
            infoText.centerXAnchor.constraint(equalTo: infoIcon.centerXAnchor),
            infoText.topAnchor.constraint(equalTo: infoIcon.bottomAnchor, constant: 5),
            
            themeText.centerXAnchor.constraint(equalTo: themeIcon.centerXAnchor),
            themeText.topAnchor.constraint(equalTo: themeIcon.bottomAnchor, constant: 5),
            
            completeText.centerXAnchor.constraint(equalTo: completeIcon.centerXAnchor),
            completeText.topAnchor.constraint(equalTo: completeIcon.bottomAnchor, constant: 5),
        ])
    }
    
    private func updateUI() {
        progressLine.setProgress(Float(progress) / 3.0, animated: true)

        func animateIconChange(icon: UIImageView, newImage: UIImage?, backgroundColor: UIColor?) {
            UIView.transition(with: icon, duration: 0.5, options: .transitionCrossDissolve, animations: {
                icon.image = newImage
                icon.backgroundColor = backgroundColor
            }, completion: nil)
        }

        func animateTextColorChange(label: UILabel, newColor: UIColor?) {
            UIView.transition(with: label, duration: 1.0, options: .transitionCrossDissolve, animations: {
                label.textColor = newColor
            }, completion: nil)
        }

        switch progress {
        case 0:
            animateIconChange(icon: transportIcon, newImage: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: infoIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: .systemBackground)
            animateIconChange(icon: themeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: .systemBackground)
            animateIconChange(icon: completeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: .systemBackground)

            animateTextColorChange(label: transportText, newColor: UIColor.label)
            animateTextColorChange(label: infoText, newColor: progressDeactivateGray)
            animateTextColorChange(label: themeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: completeText, newColor: progressDeactivateGray)
        case 1:
            animateIconChange(icon: transportIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: infoIcon, newImage: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: themeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: .systemBackground)
            animateIconChange(icon: completeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: .systemBackground)

            animateTextColorChange(label: transportText, newColor: progressDeactivateGray)
            animateTextColorChange(label: infoText, newColor: UIColor.label)
            animateTextColorChange(label: themeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: completeText, newColor: progressDeactivateGray)
        case 2:
            animateIconChange(icon: transportIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: infoIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: themeIcon, newImage: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: completeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: .systemBackground)

            animateTextColorChange(label: transportText, newColor: progressDeactivateGray)
            animateTextColorChange(label: infoText, newColor: progressDeactivateGray)
            animateTextColorChange(label: themeText, newColor: UIColor.label)
            animateTextColorChange(label: completeText, newColor: progressDeactivateGray)
        case 3:
            animateIconChange(icon: transportIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: infoIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: themeIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: completeIcon, newImage: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)

            animateTextColorChange(label: transportText, newColor: progressDeactivateGray)
            animateTextColorChange(label: infoText, newColor: progressDeactivateGray)
            animateTextColorChange(label: themeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: completeText, newColor: UIColor(named: "LabelsPrimary"))
        case 4:
            animateIconChange(icon: transportIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: infoIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: themeIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: completeIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)

            animateTextColorChange(label: transportText, newColor: progressDeactivateGray)
            animateTextColorChange(label: infoText, newColor: progressDeactivateGray)
            animateTextColorChange(label: themeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: completeText, newColor: progressDeactivateGray)
        default:
            break
        }
    }
}


// MARK: - PREVIEW
#Preview {
    PlanProgressBar(progress: 1)
}
