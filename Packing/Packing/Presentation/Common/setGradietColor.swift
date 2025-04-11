//
//  setGradietColor.swift
//  Packing
//
//  Created by 이융의 on 4/9/25.
//

import UIKit

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
