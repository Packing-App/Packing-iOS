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
    
    // MARK: - UI Components
    private lazy var navigationTitleLabel: UILabel = {
        let label = UILabel()
        let attachmentString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "logoIconWhite")
        imageAttachment.bounds = CGRect(x: 0, y: -7, width: 24, height: 24)
        attachmentString.append(NSAttributedString(attachment: imageAttachment))
        attachmentString.append(NSAttributedString(string: " 패킹".localized))
        label.attributedText = attachmentString
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingView = UIView()
    private let loadingMessageLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var loadingLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logoIcon")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let contentView = UIView()
    private let scrollView = UIScrollView()
    private let containerStackView = UIStackView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let selectAllButton = UIButton(type: .system)
    private let addItemsButton = UIButton(type: .system)
    
    // Category emoji mapping
    private let categoryEmojis: [ItemCategory: String] = [
        .clothing: "👕",
        .electronics: "📱",
        .toiletries: "🧴",
        .documents: "📄",
        .medicines: "💊",
        .essentials: "🎒",
        .other: "🔍"
    ]
    
    // Item control mappings
    private var itemSteppers: [String: UIStepper] = [:]
    private var itemCountLabels: [String: UILabel] = [:]
    private var itemCheckboxes: [String: UIButton] = [:]
    private var categorySelectButtons: [String: UIButton] = [:]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIComponents()
        setupViewHierarchy()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupUIComponents() {
        view.backgroundColor = .systemBackground
        
        // Loading view
        loadingView.backgroundColor = .systemBackground
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingMessageLabel.numberOfLines = 0
        loadingMessageLabel.textAlignment = .center
        loadingMessageLabel.font = .systemFont(ofSize: 18, weight: .medium)
        loadingMessageLabel.textColor = .label
        loadingMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.color = .main
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Content view
        contentView.backgroundColor = .systemBackground
        contentView.isHidden = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        containerStackView.axis = .vertical
        containerStackView.spacing = 24
        containerStackView.alignment = .fill
        containerStackView.distribution = .equalSpacing
        containerStackView.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Labels
        titleLabel.text = "추천 준비물".localized
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = "여행에 필요한 준비물을 확인하고 체크해보세요".localized
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Action buttons
        selectAllButton.setTitle("전체 선택".localized, for: .normal)
        selectAllButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        selectAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        addItemsButton.setTitle("0개 담기".localized, for: .normal)
        addItemsButton.setTitleColor(.white, for: .normal)
        addItemsButton.backgroundColor = .main
        addItemsButton.layer.cornerRadius = 12
        addItemsButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addItemsButton.translatesAutoresizingMaskIntoConstraints = false
        addItemsButton.isEnabled = false
        addItemsButton.alpha = 0.5
    }
    
    private func setupViewHierarchy() {
        // Navigation bar setup
        navigationItem.titleView = navigationTitleLabel
        
        // Loading view hierarchy
        loadingView.addSubview(loadingMessageLabel)
        loadingView.addSubview(loadingIndicator)
        loadingView.addSubview(loadingLogoImageView)
        view.addSubview(loadingView)
        
        // Content view hierarchy
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(subtitleLabel)
        containerStackView.addArrangedSubview(selectAllButton)
        
        scrollView.addSubview(containerStackView)
        contentView.addSubview(scrollView)
        view.addSubview(contentView)
        
        // Bottom button
        view.addSubview(addItemsButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Loading view
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingMessageLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingMessageLabel.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -30),
            loadingMessageLabel.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 20),
            loadingMessageLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: -20),
            
            loadingLogoImageView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingLogoImageView.bottomAnchor.constraint(equalTo: loadingMessageLabel.topAnchor, constant: -20),
            loadingLogoImageView.widthAnchor.constraint(equalToConstant: 100),
            loadingLogoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: loadingMessageLabel.bottomAnchor, constant: 20),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: addItemsButton.topAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            containerStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Add items button
            addItemsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addItemsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addItemsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addItemsButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    // MARK: - ReactorKit Binding
    func bind(reactor: Reactor) {
        // Setup initial debugging
        print("Binding to reactor")
        
        // Action bindings
        bindActions(reactor)
        
        // State bindings
        bindStateToUI(reactor)
    }
    
    private func bindActions(_ reactor: Reactor) {
        // Add items button action
        addItemsButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.addSelectedItems }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Select all button action
        selectAllButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self, let reactor = self.reactor else { return }
                let currentSelectedCount = reactor.currentState.selectedItems.filter { $0.value > 0 }.count
                let totalItemCount = reactor.currentState.selectedItems.count
                
                // Determine if we should select or deselect all
                let shouldSelect = currentSelectedCount < totalItemCount
                
                // Update button text
                self.selectAllButton.setTitle(shouldSelect ? "전체 해제".localized : "전체 선택".localized, for: .normal)
                
                // Send action to reactor
                reactor.action.onNext(.selectAll(select: shouldSelect))
                
                print("Select all button tapped, shouldSelect: \(shouldSelect)")
            })
            .disposed(by: disposeBag)
    }
    
    private func bindStateToUI(_ reactor: Reactor) {
        // Loading message binding
        reactor.state
            .map { $0.loadingMessage }
            .distinctUntilChanged()
            .bind(to: loadingMessageLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Loading state binding
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                
                self.loadingView.isHidden = !isLoading
                self.contentView.isHidden = isLoading
                self.addItemsButton.isHidden = isLoading
                
                if isLoading {
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.stopAnimating()
                    print("Loading finished, content should be visible")
                }
            })
            .disposed(by: disposeBag)
        
        // Categories binding
        reactor.state
            .map { $0.categories }
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] categories in
                guard let self = self else { return }
                print("Updating categories: \(categories.keys.joined(separator: ", "))")
                self.updateCategories(categories)
            })
            .disposed(by: disposeBag)
        
        // Selected items binding
        reactor.state
            .map { $0.selectedItems }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selectedItems in
                guard let self = self else { return }
                
                // Count selected items (count > 0)
                let selectedCount = selectedItems.filter { $0.value > 0 }.count
                
                // Update UI based on selection state
                self.updateSelectionUI(selectedItems: selectedItems, selectedCount: selectedCount)
                
                print("Selected items updated, count: \(selectedCount)")
            })
            .disposed(by: disposeBag)
        
        // Loading indicator for add items action
        reactor.state
            .map { $0.isProcessingAddItems }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isProcessing in
                guard let self = self else { return }
                
                self.updateAddButtonLoadingState(isProcessing: isProcessing)
            })
            .disposed(by: disposeBag)
        
        // 아이템 추가 결과 처리
        reactor.state.map { $0.addItemsResult }
            .filter { $0 != nil }
            .take(1) // 첫 번째 성공 이벤트만 처리
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let result = result, result.success else { return }
                
                // 성공했으면 메인 화면으로 이동
                self?.navigateToMainScreen()
            })
            .disposed(by: disposeBag)
        
        // Error handling
        reactor.state
            .map { $0.error }
            .filter { $0 != nil }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let error = error else { return }
                self?.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Update Methods
    private func updateCategories(_ categories: [String: RecommendationCategory]) {
        // Remove existing category views except for title, subtitle, and select all button
        let viewsToKeep = [titleLabel, subtitleLabel, selectAllButton]
        
        for view in containerStackView.arrangedSubviews {
            if !viewsToKeep.contains(where: { $0 === view }) {
                containerStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
        
        // Clear mappings
        itemSteppers.removeAll()
        itemCountLabels.removeAll()
        itemCheckboxes.removeAll()
        categorySelectButtons.removeAll()
        
        // Add category views
        for categoryKey in ItemCategory.allCases {
            guard let category = categories[categoryKey.rawValue],
                  !category.items.isEmpty else { continue }
            
            let categoryView = createCategoryView(category: category, categoryKey: categoryKey)
            containerStackView.addArrangedSubview(categoryView)
        }
        
        // Force layout update
        containerStackView.layoutIfNeeded()
    }
    
    private func updateSelectionUI(selectedItems: [String: Int], selectedCount: Int) {
        // Update add items button
        addItemsButton.setTitle("\(selectedCount)개 담기".localized, for: .normal)
        addItemsButton.isEnabled = selectedCount > 0
        addItemsButton.alpha = selectedCount > 0 ? 1.0 : 0.5
        
        // Update global select all button
        let totalItems = itemCheckboxes.count
        selectAllButton.setTitle(selectedCount == totalItems ? "전체 해제".localized : "전체 선택".localized, for: .normal)
        
        // Update category select all buttons
        updateCategorySelectButtons()
        
        // Update item UI elements
        for (itemName, count) in selectedItems {
            if let checkbox = itemCheckboxes[itemName] {
                checkbox.isSelected = count > 0
            }
            
            if let stepper = itemSteppers[itemName] {
                if stepper.value != Double(count) {
                    stepper.value = Double(max(count, 0))
                }
            }
            
            if let countLabel = itemCountLabels[itemName] {
                countLabel.text = count > 0 ? "\(count)개".localized : ""
            }
        }
    }
    
    private func updateCategorySelectButtons() {
        guard let reactor = self.reactor else { return }
        
        for (category, button) in categorySelectButtons {
            // Get all items in this category
            guard let categoryItems = reactor.currentState.categories[category]?.items else { continue }
            
            // Count how many items are selected in this category
            var selectedInCategory = 0
            for item in categoryItems {
                if let count = reactor.currentState.selectedItems[item.name], count > 0 {
                    selectedInCategory += 1
                }
            }
            
            // Update button state and title
            let allSelected = selectedInCategory == categoryItems.count && categoryItems.count > 0
            button.isSelected = allSelected
            button.setTitle(allSelected ? "전체 해제".localized : "전체 선택".localized, for: .normal)
        }
    }
    
    private func updateAddButtonLoadingState(isProcessing: Bool) {
        addItemsButton.isEnabled = !isProcessing
        
        // Remove any existing activity indicators
        for subview in addItemsButton.subviews {
            if subview is UIActivityIndicatorView {
                subview.removeFromSuperview()
            }
        }
        
        if isProcessing {
            // Add activity indicator
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color = .white
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            addItemsButton.setTitle("", for: .normal)
            addItemsButton.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: addItemsButton.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: addItemsButton.centerYAnchor)
            ])
        } else {
            // Restore button title
            guard let reactor = reactor else { return }
            let selectedCount = reactor.currentState.selectedItems.filter { $0.value > 0 }.count
            addItemsButton.setTitle("\(selectedCount)개 담기".localized, for: .normal)
        }
    }
    
    // MARK: - UI Creation Methods
    private func createCategoryView(category: RecommendationCategory, categoryKey: ItemCategory) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Header view with category title and select all button
        let headerView = createCategoryHeaderView(category: category, categoryKey: categoryKey)
        stackView.addArrangedSubview(headerView)
        
        // Add separator
        let separator = UIView()
        separator.backgroundColor = .systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(separator)
        
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
    
    private func createCategoryHeaderView(category: RecommendationCategory, categoryKey: ItemCategory) -> UIView {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Category title with emoji
        let titleLabel = UILabel()
        let emoji = categoryEmojis[categoryKey] ?? "📦"
        titleLabel.text = "\(emoji) \(category.name)"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Category select all button
        let selectAllButton = UIButton(type: .system)
        selectAllButton.setTitle("전체 선택".localized, for: .normal)
        selectAllButton.titleLabel?.font = .systemFont(ofSize: 14)
        selectAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Store reference to this button
        categorySelectButtons[categoryKey.rawValue] = selectAllButton
        
        // Add button action
        selectAllButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self, weak selectAllButton] in
                guard let self = self, let reactor = self.reactor else { return }
                
                // Toggle selection state
                let shouldSelect = !(selectAllButton?.isSelected ?? false)
                
                // Update button text
                selectAllButton?.isSelected = shouldSelect
                selectAllButton?.setTitle(shouldSelect ? "전체 해제".localized : "전체 선택".localized, for: .normal)
                
                // Send action to reactor
                reactor.action.onNext(.selectAllInCategory(category: categoryKey.rawValue, select: shouldSelect))
                
                print("Category select button tapped: \(categoryKey.rawValue), shouldSelect: \(shouldSelect)")
            })
            .disposed(by: disposeBag)
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(selectAllButton)
        
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            selectAllButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            selectAllButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    private func createItemView(item: RecommendedItem) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Checkbox
        let checkboxButton = UIButton(type: .custom)
        checkboxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkboxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        checkboxButton.tintColor = .main
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Item name
        let nameLabel = UILabel()
        nameLabel.text = item.name
        nameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Count label
        let countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 14, weight: .regular)
        countLabel.textColor = .secondaryLabel
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Stepper for quantity
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 99
        stepper.stepValue = 1
        stepper.value = Double(item.count ?? 1)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        
        // Essential badge if needed
        let essentialBadge = UILabel()
        if item.isEssential {
            essentialBadge.text = "필수".localized
            essentialBadge.font = .systemFont(ofSize: 12, weight: .medium)
            essentialBadge.textColor = .white
            essentialBadge.backgroundColor = .systemRed
            essentialBadge.textAlignment = .center
            essentialBadge.layer.cornerRadius = 4
            essentialBadge.clipsToBounds = true
            essentialBadge.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Add subviews
        containerView.addSubview(checkboxButton)
        containerView.addSubview(nameLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(stepper)
        
        if item.isEssential {
            containerView.addSubview(essentialBadge)
        }
        
        // Store UI element references
        itemCheckboxes[item.name] = checkboxButton
        itemSteppers[item.name] = stepper
        itemCountLabels[item.name] = countLabel
        
        // Setup layout
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 44),
            
            checkboxButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])
        
        if item.isEssential {
            NSLayoutConstraint.activate([
                essentialBadge.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
                essentialBadge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                essentialBadge.widthAnchor.constraint(equalToConstant: 36),
                essentialBadge.heightAnchor.constraint(equalToConstant: 20),
                
                countLabel.leadingAnchor.constraint(equalTo: essentialBadge.trailingAnchor, constant: 8),
                countLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
                stepper.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                stepper.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                countLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
                countLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
                stepper.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                stepper.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        }
        
        // Bind checkbox tap
        checkboxButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self, weak checkboxButton] in
                guard let self = self, let reactor = self.reactor else { return }
                
                // Toggle checkbox visually immediately for better UX
                let isCurrentlySelected = checkboxButton?.isSelected ?? false
                checkboxButton?.isSelected = !isCurrentlySelected
                
                // Update reactor
                reactor.action.onNext(.toggleItem(itemName: item.name))
                
                print("Checkbox tapped for: \(item.name), new visual state: \(!isCurrentlySelected)")
            })
            .disposed(by: disposeBag)
        
        // Bind stepper value changes
        stepper.rx.value
            .skip(1) // Skip initial value
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateItemCount(itemName: item.name, count: Int($0)) }
            .subscribe(onNext: { [weak self] action in
                guard let reactor = self?.reactor else { return }
                reactor.action.onNext(action)
                
                print("Stepper changed for: \(item.name), new value: \(Int(stepper.value))")
            })
            .disposed(by: disposeBag)
        
        return containerView
    }
    
    // MARK: - Utility Methods
    private func showError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
        
        let alert = UIAlertController(
            title: "오류".localized,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인".localized, style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToMainScreen() {
        AuthCoordinator.shared.showMainScreen()
    }
}
