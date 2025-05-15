//
//  UIView.swift
//  Packing
//
//  Created by 이융의 on 5/2/25.
//

import UIKit

// MARK: - UIView Extension
extension UIView {
    func applyShadow(color: UIColor = .black, opacity: Float = 0.1, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    func roundCorners(radius: CGFloat = 8) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}

// MARK: - UIButton Extension
extension UIButton {
    func applyPrimaryStyle(title: String) {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = .main
        configuration.buttonSize = .large
        configuration.title = title
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        
        self.configuration = configuration
        self.applyShadow()
    }
    
    func applySecondaryStyle(title: String) {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = .white.withAlphaComponent(0.25)
        configuration.buttonSize = .large
        configuration.title = title
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        
        self.configuration = configuration
        self.applyShadow()
    }
}

// MARK: - UILabel Extension
extension UILabel {
    func asColor(targetString: String, color: UIColor) {
        let fullText = text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: targetString)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        attributedText = attributedString
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func withRoundedCorners(radius: CGFloat = 8) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
        context?.clip()
        
        draw(in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

// MARK: - UIColor Extension
extension UIColor {
    
    // Useful for theme colors
    static let accentColor = UIColor(red: 255/255, green: 99/255, blue: 99/255, alpha: 1.0)
    static let background = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0)
    static let textPrimary = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
    static let textSecondary = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
}


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


extension UIView {
    @discardableResult
    func setGradientColor(colorOne: UIColor, colorTwo: UIColor) -> CALayer {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        layer.insertSublayer(gradientLayer, at: 0)
        return layer
    }
}

// MARK: - Localization

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
