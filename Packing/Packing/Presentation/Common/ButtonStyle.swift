//
//  ButtonStyle.swift
//  Packing
//
//  Created by 이융의 on 3/31/25.
//

import UIKit

// 버튼 스타일 프로토콜
protocol ButtonStyle {
    var color: UIColor? { get }
    func makeConfiguration() -> UIButton.Configuration
}

class MainButtonStyle: ButtonStyle {
    let color: UIColor?
    init(color: UIColor) {
        self.color = color
    }
    func makeConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = color
        configuration.baseForegroundColor = .white
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        configuration.cornerStyle = .medium
        return configuration
    }
}

extension UIButton {
    func applyStyle(_ style: ButtonStyle) {
        self.configuration = style.makeConfiguration()
        
        // 버튼 눌렀을 때 효과 추가
        self.configurationUpdateHandler = { button in
            var config = button.configuration
            let alpha = button.isHighlighted ? 0.8 : 1.0
            config?.background.backgroundColor = style.color?.withAlphaComponent(alpha)
            button.configuration = config
        }
    }
}
