//
//  ItemCell.swift
//  Packing
//
//  Created by 이융의 on 4/26/25.
//

import UIKit

class ItemCell: UITableViewCell {
    
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
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(essentialIndicator)
        stackView.addArrangedSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            essentialIndicator.widthAnchor.constraint(equalToConstant: 8),
            essentialIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    func configure(with item: RecommendedItem) {
        nameLabel.text = item.name
        essentialIndicator.isHidden = !item.isEssential
    }
}
