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
    
    // MARK: - UI COMPONENTS
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureNavigationBar()
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
        
        // 테이블뷰 섹션 바인딩
        reactor.state
            .observe(on: MainScheduler.instance)
            .map { $0.categories.count }
            .distinctUntilChanged()
            .bind(to: tableView.rx.observableNumberOfSections)
            .disposed(by: disposeBag)
        
        // 테이블뷰 셀 바인딩
        reactor.state
            .observe(on: MainScheduler.instance)
            .compactMap { state -> [String: [RecommendedItem]]? in
                return state.template != nil ? state.groupedItems : nil
            }
            .share()
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 카테고리로 섹션 header 제공
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    // MARK: - SETUP UI
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureNavigationBar() {
        title = themeName.displayName + " 준비물"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension ThemeTemplateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let reactor = reactor,
              let categories = reactor.currentState.categories[safe: section] else {
            return nil
        }
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        
        // 카테고리명을 사용자 친화적인 형태로 변환
        if let category = ItemCategory(rawValue: categories) {
            titleLabel.text = category.displayName
        } else {
            titleLabel.text = categories
        }
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
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
}

// 인덱스 안전 접근을 위한 확장
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Reactive where Base: UITableView {
    var observableNumberOfSections: Binder<Int> {
        return Binder(self.base) { tableView, count in
            tableView.numberOfSections = count
        }
    }
}

extension UITableView {
    var numberOfSections: Int {
        get {
            return dataSource?.numberOfSections?(in: self) ?? 0
        }
        set {
            self.reloadData()
        }
    }
}
