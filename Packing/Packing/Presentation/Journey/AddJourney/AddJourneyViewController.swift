//
//  AddJourneyViewController.swift
//  Packing
//
//  Created by 이융의 on 4/13/25.
//

import UIKit

extension UIColor {
    
    //hex 코드로 UIColor 만들기
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}


extension UILabel {
    //자간 수정 기능
    func addCharacterSpacing(_ value: Double = -0.03) {
        let kernValue = self.font.pointSize * CGFloat(value)
        guard let text = text, !text.isEmpty else { return }
        let string = NSMutableAttributedString(string: text)
        string.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: string.length - 1))
        attributedText = string
    }
}

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
        transportText.text = "이동수단"
        transportText.font = UIFont.systemFont(ofSize: 10)
        transportText.addCharacterSpacing(-0.025)
        transportText.translatesAutoresizingMaskIntoConstraints = false
        return transportText
    }()
    
    private lazy var infoText: UILabel = {
        let infoText = UILabel()
        infoText.text = "여행정보"
        infoText.font = UIFont.systemFont(ofSize: 10)
        infoText.addCharacterSpacing(-0.025)
        infoText.translatesAutoresizingMaskIntoConstraints = false
        return infoText
    }()
    
    private lazy var themeText: UILabel = {
        let themeText = UILabel()
        themeText.text = "여행테마"
        themeText.font = UIFont.systemFont(ofSize: 10)
        themeText.addCharacterSpacing(-0.025)
        themeText.translatesAutoresizingMaskIntoConstraints = false
        return themeText
    }()
    
    private lazy var completeText: UILabel = {
        let completeText = UILabel()
        completeText.text = "완료"
        completeText.font = UIFont.systemFont(ofSize: 10)
        completeText.addCharacterSpacing(-0.025)
        completeText.translatesAutoresizingMaskIntoConstraints = false
        return completeText
    }()
    
    private func setupUI() {
        self.addSubview(progressLine)
        self.addSubview(transportIcon)
        self.addSubview(infoIcon)
        self.addSubview(themeIcon)
        self.addSubview(completeIcon)
        self.addSubview(transportText)
        self.addSubview(infoText)
        self.addSubview(themeText)
        self.addSubview(completeText)
        
        NSLayoutConstraint.activate([
            progressLine.heightAnchor.constraint(equalToConstant: 1),
            progressLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48),
            progressLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48),
            progressLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            transportIcon.heightAnchor.constraint(equalToConstant: 20),
            transportIcon.widthAnchor.constraint(equalToConstant: 20),
            transportIcon.centerXAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            transportIcon.centerYAnchor.constraint(equalTo: progressLine.centerYAnchor),
            
            infoIcon.heightAnchor.constraint(equalToConstant: 20),
            infoIcon.widthAnchor.constraint(equalToConstant: 20),
            infoIcon.centerXAnchor.constraint(equalTo: leadingAnchor, constant: progressLine.frame.width / 3),
            infoIcon.centerYAnchor.constraint(equalTo: progressLine.centerYAnchor),
            
            themeIcon.heightAnchor.constraint(equalToConstant: 20),
            themeIcon.widthAnchor.constraint(equalToConstant: 20),
            themeIcon.centerXAnchor.constraint(equalTo: leadingAnchor, constant: progressLine.frame.width * 2 / 3),
            themeIcon.centerYAnchor.constraint(equalTo: progressLine.centerYAnchor),
            
            completeIcon.heightAnchor.constraint(equalToConstant: 20),
            completeIcon.widthAnchor.constraint(equalToConstant: 20),
            completeIcon.centerXAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            completeIcon.centerYAnchor.constraint(equalTo: progressLine.centerYAnchor),
            
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
            animateIconChange(icon: infoIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: UIColor(named: "BGSecondary"))
            animateIconChange(icon: themeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: UIColor(named: "BGSecondary"))
            animateIconChange(icon: completeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: UIColor(named: "BGSecondary"))

            animateTextColorChange(label: transportText, newColor: UIColor(named: "LabelsPrimary"))
            animateTextColorChange(label: infoText, newColor: progressDeactivateGray)
            animateTextColorChange(label: themeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: completeText, newColor: progressDeactivateGray)
        case 1:
            animateIconChange(icon: transportIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: infoIcon, newImage: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: themeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: UIColor(named: "BGSecondary"))
            animateIconChange(icon: completeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: UIColor(named: "BGSecondary"))

            animateTextColorChange(label: transportText, newColor: progressDeactivateGray)
            animateTextColorChange(label: infoText, newColor: UIColor(named: "LabelsPrimary"))
            animateTextColorChange(label: themeText, newColor: progressDeactivateGray)
            animateTextColorChange(label: completeText, newColor: progressDeactivateGray)
        case 2:
            animateIconChange(icon: transportIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: infoIcon, newImage: UIImage(systemName: "checkmark.circle.fill")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: themeIcon, newImage: UIImage(systemName: "smallcircle.filled.circle")?.withTintColor(progressBlue, renderingMode: .alwaysOriginal), backgroundColor: .white)
            animateIconChange(icon: completeIcon, newImage: UIImage(systemName: "circle")?.withTintColor(progressGray, renderingMode: .alwaysOriginal), backgroundColor: UIColor(named: "BGSecondary"))

            animateTextColorChange(label: transportText, newColor: progressDeactivateGray)
            animateTextColorChange(label: infoText, newColor: progressDeactivateGray)
            animateTextColorChange(label: themeText, newColor: UIColor(named: "LabelsPrimary"))
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
