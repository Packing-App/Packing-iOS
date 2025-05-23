//
//  LocationSearchViewController.swift
//  Packing
//
//  Created by 이융의 on 5/3/25.
//

import UIKit
import RxSwift

// MARK: - LocationSearchViewController
class LocationSearchViewController: UIViewController {
    
    enum SearchType {
        case departure
        case destination
    }
    
    private let searchType: SearchType
    var completion: ((String) -> Void)?
    
    // MARK: - UI Elements
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "여행지 검색".localized
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    private let locationService = LocationService()
    private let disposeBag = DisposeBag()
    private var searchResults: [CitySearchResult] = []
    private var searchDebouncer = PublishSubject<String>()
    
    // MARK: - Init
    init(searchType: SearchType) {
        self.searchType = searchType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        setupRx()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add search bar
        view.addSubview(searchBar)
        searchBar.delegate = self
        
        // Add table view
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let title = searchType == .departure ? "출발지 선택".localized : "목적지 선택".localized
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        
        tableView.tableHeaderView = titleLabel
    }
    
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupRx() {
        // 검색어 디바운싱 처리
        searchDebouncer
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { [weak self] query -> Observable<[CitySearchResult]> in
                guard let self = self else { return Observable.just([]) }
                
                // 로딩 인디케이터 표시
                let activityIndicator = UIActivityIndicatorView(style: .medium)
                activityIndicator.startAnimating()
                self.tableView.tableFooterView = activityIndicator
                
                // 쿼리가 비어있으면 기본 인기 도시 목록 표시
                if query.isEmpty {
                    return Observable.just(self.getDefaultCities())
                }
                
                return self.locationService.searchLocations(query: query, limit: 20)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] results in
                self?.searchResults = results
                self?.tableView.reloadData()
                self?.tableView.tableFooterView = nil
            })
            .disposed(by: disposeBag)
        
        // 초기 검색 결과 로드 (인기 도시)
        searchDebouncer.onNext("")  // 빈 검색어로 기본 인기 도시 로드
    }
    
    // MARK: - Helper Methods
    private var isKoreanUser: Bool {
        return Locale.current.language.languageCode?.identifier == "ko"
    }
    
    private func displayName(for city: CitySearchResult) -> String {
        return isKoreanUser ? city.korName : city.engName
    }
    
    private func secondaryText(for city: CitySearchResult) -> String {
        if isKoreanUser {
            return "\(city.engName), \(city.countryCode)"
        } else {
            // 영어 사용자에게는 한국어 이름을 작게 표시
            return "\(city.korName), \(city.countryCode)"
            // 한국어 이름을 제외하고 국가 코드만 표시하려면:
            // return city.countryCode
        }
    }
    
    private func getDefaultCities() -> [CitySearchResult] {
        if isKoreanUser {
            return [
                CitySearchResult(korName: "서울", engName: "Seoul", countryCode: "KR"),
                CitySearchResult(korName: "부산", engName: "Busan", countryCode: "KR"),
                CitySearchResult(korName: "도쿄", engName: "Tokyo", countryCode: "JP"),
                CitySearchResult(korName: "오사카", engName: "Osaka", countryCode: "JP"),
                CitySearchResult(korName: "파리", engName: "Paris", countryCode: "FR"),
                CitySearchResult(korName: "뉴욕", engName: "New York", countryCode: "US"),
                CitySearchResult(korName: "방콕", engName: "Bangkok", countryCode: "TH")
            ]
        } else {
            return [
                CitySearchResult(korName: "뉴욕", engName: "New York", countryCode: "US"),
                CitySearchResult(korName: "런던", engName: "London", countryCode: "GB"),
                CitySearchResult(korName: "파리", engName: "Paris", countryCode: "FR"),
                CitySearchResult(korName: "도쿄", engName: "Tokyo", countryCode: "JP"),
                CitySearchResult(korName: "싱가포르", engName: "Singapore", countryCode: "SG"),
                CitySearchResult(korName: "홍콩", engName: "Hong Kong", countryCode: "HK"),
                CitySearchResult(korName: "로스앤젤레스", engName: "Los Angeles", countryCode: "US")
            ]
        }
    }
}

// MARK: - UISearchBarDelegate
extension LocationSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDebouncer.onNext(searchText)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension LocationSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
        let city = searchResults[indexPath.row]
        
        var content = UIListContentConfiguration.cell()
        content.text = displayName(for: city)
        content.secondaryText = secondaryText(for: city)
        
        // 영어 사용자의 경우 보조 텍스트를 더 작게 표시
        if !isKoreanUser {
            content.secondaryTextProperties.font = .systemFont(ofSize: 12)
            content.secondaryTextProperties.color = .secondaryLabel
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCity = searchResults[indexPath.row]
        
        // 선택 시에도 언어에 따라 다른 값 반환
        let selectedName = displayName(for: selectedCity)
        
        completion?(selectedName)
        dismiss(animated: true)
    }
}
