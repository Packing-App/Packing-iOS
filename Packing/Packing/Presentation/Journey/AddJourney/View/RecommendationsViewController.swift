//
//  RecommendationsViewController.swift
//  Packing
//
//  Created by 이융의 on 4/23/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class RecommendationsViewController: UIViewController, View {
    
    // MARK: - Properties
    typealias Reactor = RecommendationsReactor
    
    var disposeBag = DisposeBag()
    
    private lazy var navigationTitleLabel: UILabel = {
        let label = UILabel()
        let attachmentString = NSMutableAttributedString(string: "")
        let imageAttachment: NSTextAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "logoIconWhite")
        imageAttachment.bounds = CGRect(x: 0, y: -7, width: 24, height: 24)
        attachmentString.append(NSAttributedString(attachment: imageAttachment))
        attachmentString.append(NSAttributedString(string: " PACKING"))
        label.attributedText = attachmentString
        label.sizeToFit()
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .main
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "추천 준비물"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "여행에 필요한 준비물을 확인하고 체크해보세요"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("홈으로 이동", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .main
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationTitleLabel)
        
        view.addSubview(loadingView)
        loadingView.addSubview(loadingMessageLabel)
        loadingView.addSubview(loadingIndicator)
        
        view.addSubview(contentView)
        contentView.addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(subtitleLabel)
        
        view.addSubview(homeButton)
        
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Loading View
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingMessageLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingMessageLabel.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -30),
            loadingMessageLabel.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 20),
            loadingMessageLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: -20),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: loadingMessageLabel.bottomAnchor, constant: 20),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: homeButton.topAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            containerStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Home Button
            homeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            homeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            homeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            homeButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    // MARK: - Binding
    func bind(reactor: Reactor) {
        // Actions
        
        // States
        reactor.state.map { $0.loadingMessage }
            .observe(on: MainScheduler.instance)
            .bind(to: loadingMessageLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
                self?.contentView.isHidden = isLoading
                
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.categories }
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] categories in
                self?.updateCategories(categories)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.error }
            .filter { $0 != nil }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showError(error!)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func updateCategories(_ categories: [String: RecommendationCategory]) {
        // Remove existing category views
        containerStackView.arrangedSubviews.forEach {
            if $0 !== titleLabel && $0 !== subtitleLabel {
                containerStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
        }
        
        // Add category views
        let categoryOrder = ["clothing", "essentials", "documents", "electronics", "toiletries", "medicines", "other"]
        
        for categoryKey in categoryOrder {
            guard let category = categories[categoryKey],
                  !category.items.isEmpty else { continue }
            
            let categoryView = createCategoryView(category: category)
            containerStackView.addArrangedSubview(categoryView)
        }
    }
    
    private func createCategoryView(category: RecommendationCategory) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = category.name
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        
        stackView.addArrangedSubview(titleLabel)
        
        // Add items
        for item in category.items {
            let itemView = createItemView(item: item)
            stackView.addArrangedSubview(itemView)
        }
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createItemView(item: RecommendedItem) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let checkboxButton = UIButton(type: .system)
        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkboxButton.tintColor = .main
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = item.name
        nameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let countLabel = UILabel()
        if let count = item.count {
            countLabel.text = "\(count)개"
            countLabel.font = .systemFont(ofSize: 14, weight: .regular)
            countLabel.textColor = .secondaryLabel
        }
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let essentialBadge = UILabel()
        if item.isEssential {
            essentialBadge.text = "필수"
            essentialBadge.font = .systemFont(ofSize: 12, weight: .medium)
            essentialBadge.textColor = .white
            essentialBadge.backgroundColor = .systemRed
            essentialBadge.textAlignment = .center
            essentialBadge.layer.cornerRadius = 4
            essentialBadge.layer.masksToBounds = true
            essentialBadge.translatesAutoresizingMaskIntoConstraints = false
        }
        
        containerView.addSubview(checkboxButton)
        containerView.addSubview(nameLabel)
        containerView.addSubview(countLabel)
        if item.isEssential {
            containerView.addSubview(essentialBadge)
        }
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 44),
            
            checkboxButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        if item.isEssential {
            NSLayoutConstraint.activate([
                essentialBadge.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
                essentialBadge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                essentialBadge.widthAnchor.constraint(equalToConstant: 36),
                essentialBadge.heightAnchor.constraint(equalToConstant: 20),
                
                countLabel.leadingAnchor.constraint(equalTo: essentialBadge.trailingAnchor, constant: 8),
                countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                countLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                countLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
                countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                countLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        }
        
        checkboxButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        
        return containerView
    }
    
    @objc private func checkboxTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @objc private func homeButtonTapped() {
        navigateToMainScreen()
    }
    
    private func navigateToMainScreen() {
        AuthCoordinator.shared.showMainScreen()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
