//
//  ThemeTemplateViewController.swift
//  Packing
//
//  Created by 이융의 on 4/26/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class ThemeTemplateViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    var themeName: TravelTheme!
    
    // 선택된 아이템을 추적하기 위한 배열
    private var selectedItems: [IndexPath] = []
    
    // MARK: - UI COMPONENTS
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.estimatedRowHeight = 60 // 높이 약간 증가
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
        tableView.allowsMultipleSelection = true
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 100, right: 0) // 여백 추가
        return tableView
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var themeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var themeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "필요한 준비물을 선택하고 여행에 추가하세요"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var floatingAddButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .main
        button.setTitle("선택 항목 추가", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 그림자 효과 추가
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.2
        
        // 비활성화 상태로 시작 (선택된 항목이 없기 때문)
        button.isEnabled = false
        button.alpha = 0.7
        button.addTarget(self, action: #selector(addSelectedItemsButtonTapped), for: .touchUpInside)

        return button
    }()
    
    private lazy var selectionCountView: UIView = {
        let view = UIView()
        view.backgroundColor = .main
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var selectionCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var selectAllButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "전체 선택", style: .plain, target: self, action: #selector(selectAllButtonTapped))
        return button
    }()
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        themeTitleLabel.text = themeName.displayName + " 준비물"
        title = themeName.displayName
        tableView.dataSource = self
        tableView.delegate = self
        
        // 네비게이션 스타일 설정 - 타이틀 색상을 흰색으로
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white

        // iOS 15 이상에서 네비게이션 바 배경색 설정
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .main
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        // 네비게이션 버튼 추가
        navigationItem.rightBarButtonItem = selectAllButton
    }
    
    func bind(reactor: ThemeTemplateReactor) {
        // Action 바인딩
        Observable.just(themeName)
            .map { ThemeTemplateReactor.Action.loadTemplate(themeName: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State 바인딩
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.error }
            .distinctUntilChanged { $0?.localizedDescription == $1?.localizedDescription }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        // 데이터 변경 시 테이블뷰 리로드
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.template != nil }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - SETUP UI
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // 헤더뷰 설정
        view.addSubview(headerView)
        headerView.addSubview(themeTitleLabel)
        headerView.addSubview(themeDescriptionLabel)
        
        // 테이블뷰 및 로딩 인디케이터 추가
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        // 플로팅 버튼 및 선택 개수 뷰 추가
        view.addSubview(floatingAddButton)
        view.addSubview(selectionCountView)
        selectionCountView.addSubview(selectionCountLabel)
        
        NSLayoutConstraint.activate([
            // 헤더뷰 제약조건
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            themeTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            themeTitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            themeTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            
            themeDescriptionLabel.leadingAnchor.constraint(equalTo: themeTitleLabel.leadingAnchor),
            themeDescriptionLabel.trailingAnchor.constraint(equalTo: themeTitleLabel.trailingAnchor),
            themeDescriptionLabel.topAnchor.constraint(equalTo: themeTitleLabel.bottomAnchor, constant: 8),
            
            // 테이블뷰 제약조건
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 로딩 인디케이터 제약조건
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // 플로팅 버튼 제약조건
            floatingAddButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            floatingAddButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingAddButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            floatingAddButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 선택 개수 뷰 제약조건
            selectionCountView.trailingAnchor.constraint(equalTo: floatingAddButton.trailingAnchor, constant: -10),
            selectionCountView.topAnchor.constraint(equalTo: floatingAddButton.topAnchor, constant: -10),
            selectionCountView.widthAnchor.constraint(equalToConstant: 24),
            selectionCountView.heightAnchor.constraint(equalToConstant: 24),
            
            selectionCountLabel.centerXAnchor.constraint(equalTo: selectionCountView.centerXAnchor),
            selectionCountLabel.centerYAnchor.constraint(equalTo: selectionCountView.centerYAnchor)
        ])
    }
    
    
    @objc private func addSelectedItemsButtonTapped() {
        guard let reactor = reactor else { return }
        
        // Collect selected items information
        var selectedRecommendedItems: [SelectedRecommendedItem] = []
        
        for indexPath in selectedItems {
            if let category = reactor.currentState.categories[safe: indexPath.section],
               let items = reactor.currentState.groupedItems[category],
               indexPath.row < items.count {
                let item = items[indexPath.row]
                let selectedItem = SelectedRecommendedItem(
                    name: item.name,
                    category: item.category
                )
                selectedRecommendedItems.append(selectedItem)
            }
        }
        
        // Show journey selection view
        let journeySelectionVC = JourneySelectionViewController()
        journeySelectionVC.selectedItems = selectedRecommendedItems
        journeySelectionVC.selectionMode = .addPackingItems
        navigationController?.pushViewController(journeySelectionVC, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func updateSelectionCount() {
        let count = selectedItems.count
        
        // 선택된 항목 개수에 따라 버튼 상태 업데이트
        if count > 0 {
            floatingAddButton.isEnabled = true
            floatingAddButton.alpha = 1.0
            selectionCountView.isHidden = false
            selectionCountLabel.text = "\(count)"
        } else {
            floatingAddButton.isEnabled = false
            floatingAddButton.alpha = 0.7
            selectionCountView.isHidden = true
        }
    }
    
    @objc private func selectAllButtonTapped() {
        guard let reactor = reactor else { return }
        
        let allSelected = selectedItems.count == reactor.currentState.template?.items.count
        
        if allSelected {
            // 모든 항목 선택 해제
            selectedItems.forEach { indexPath in
                tableView.deselectRow(at: indexPath, animated: true)
                if let cell = tableView.cellForRow(at: indexPath) as? ItemCell {
                    cell.setSelected(false, animated: true)
                    // 기본 액세서리 체크마크 제거
                    cell.accessoryType = .none
                }
            }
            selectedItems.removeAll()
            selectAllButton.title = "전체 선택"
        } else {
            // 모든 항목 선택
            selectedItems.removeAll()
            
            for sectionIndex in 0..<tableView.numberOfSections {
                for rowIndex in 0..<tableView.numberOfRows(inSection: sectionIndex) {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    if let cell = tableView.cellForRow(at: indexPath) as? ItemCell {
                        cell.setSelected(true, animated: true)
                        // 기본 액세서리 체크마크 제거
                        cell.accessoryType = .none
                    }
                    selectedItems.append(indexPath)
                }
            }
            selectAllButton.title = "전체 해제"
        }
        
        updateSelectionCount()
    }
}

// MARK: - UITableViewDataSource
extension ThemeTemplateViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return reactor?.currentState.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reactor = reactor,
              let category = reactor.currentState.categories[safe: section],
              let items = reactor.currentState.groupedItems[category] else {
            return 0
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemCell,
              let reactor = reactor,
              let category = reactor.currentState.categories[safe: indexPath.section],
              let items = reactor.currentState.groupedItems[category],
              indexPath.row < items.count else {
            return UITableViewCell()
        }
        
        let item = items[indexPath.row]
        cell.configure(with: item)
        
        // 기본 액세서리 체크마크 제거
        cell.accessoryType = .none
        
        // 이미 선택된 항목인 경우 선택 상태 표시
        if selectedItems.contains(indexPath) {
            cell.setSelected(true, animated: false)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ThemeTemplateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let reactor = reactor,
              let category = reactor.currentState.categories[safe: section] else {
            return nil
        }
        
        // 섹션 헤더 스타일 개선
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = .systemFont(ofSize: 22)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .main
        
        // 카테고리별 이모지와 표시 이름 설정
        if let itemCategory = ItemCategory(rawValue: category) {
            titleLabel.text = itemCategory.displayName
            
            // 카테고리별 이모지 설정
            switch category {
            case "clothing":
                emojiLabel.text = "👕"
            case "electronics":
                emojiLabel.text = "📱"
            case "toiletries":
                emojiLabel.text = "🧴"
            case "documents":
                emojiLabel.text = "📄"
            case "medicines":
                emojiLabel.text = "💊"
            case "essentials":
                emojiLabel.text = "⭐️"
            default:
                emojiLabel.text = "📦"
            }
        } else {
            titleLabel.text = category
            emojiLabel.text = "📦"
        }
        
        // 구분선 추가
        let separatorView = UIView()
        separatorView.backgroundColor = .systemGray5
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(emojiLabel)
        stackView.addArrangedSubview(titleLabel)
        
        headerView.addSubview(stackView)
        headerView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ItemCell {
            cell.setSelected(true, animated: true)
            // 기본 액세서리 체크마크 제거
            cell.accessoryType = .none
        }
        
        // 선택된 항목 추적
        if !selectedItems.contains(indexPath) {
            selectedItems.append(indexPath)
            updateSelectionCount()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ItemCell {
            cell.setSelected(false, animated: true)
            // 기본 액세서리 체크마크 제거
            cell.accessoryType = .none
        }
        
        // 선택 해제된 항목 제거
        if let index = selectedItems.firstIndex(of: indexPath) {
            selectedItems.remove(at: index)
            updateSelectionCount()
        }
    }
}

// 인덱스 안전 접근을 위한 확장
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
