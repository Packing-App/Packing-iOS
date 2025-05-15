//
//  TravelPlanCell.swift
//  Packing
//
//  Created by 이융의 on 5/2/25.
//

import UIKit
import Kingfisher

class TravelPlanCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Add journey components
    private let addBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let plusImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        iv.tintColor = .main
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let addTripLabel: UILabel = {
        let label = UILabel()
        label.text = "여행을 추가해보세요".localized
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Cell type
    private var isEmptyCell = false
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // Add all UI components
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        contentView.addSubview(addBackgroundView)
        addBackgroundView.addSubview(plusImageView)
        contentView.addSubview(addTripLabel)
        
        NSLayoutConstraint.activate([
            // Regular journey view constraints
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Add journey view constraints
            addBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            addBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addBackgroundView.heightAnchor.constraint(equalToConstant: 120),
            
            plusImageView.centerXAnchor.constraint(equalTo: addBackgroundView.centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: addBackgroundView.centerYAnchor),
            plusImageView.widthAnchor.constraint(equalToConstant: 40),
            plusImageView.heightAnchor.constraint(equalToConstant: 40),
            
            addTripLabel.topAnchor.constraint(equalTo: addBackgroundView.bottomAnchor, constant: 8),
            addTripLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addTripLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with plan: Journey?) {
        if let plan = plan {
            // Configure with journey data
            configureWithJourney(plan)
        } else {
            // Configure as "Add Journey" cell
            configureAsAddJourneyCell()
        }
    }
    
    private func configureWithJourney(_ plan: Journey) {
        isEmptyCell = false
        
        // Show journey UI
        imageView.isHidden = false
        titleLabel.isHidden = false
        dateLabel.isHidden = false
        
        // Hide add journey UI
        addBackgroundView.isHidden = true
        plusImageView.isHidden = true
        addTripLabel.isHidden = true
        
        // Set journey data
        if let url = URL(string: plan.imageUrl ?? "") {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url)
        } else {
            // Set a default image if no URL is available
            imageView.image = UIImage(named: "defaultTravelImage")
        }
        
        titleLabel.text = plan.title
        dateLabel.text = plan.dateRangeString
    }
    
    private func configureAsAddJourneyCell() {
        isEmptyCell = true
        
        // Hide journey UI
        imageView.isHidden = true
        titleLabel.isHidden = true
        dateLabel.isHidden = true
        
        // Show add journey UI
        addBackgroundView.isHidden = false
        plusImageView.isHidden = false
        addTripLabel.isHidden = false
    }
    
    // Function to be called from data source/bindings
    func configureEmpty() {
        configureAsAddJourneyCell()
    }
    
    // Make cell reusable
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
    }
    
    // Helper to determine if this is an "add" cell
    func isAddJourneyCell() -> Bool {
        return isEmptyCell
    }
}
