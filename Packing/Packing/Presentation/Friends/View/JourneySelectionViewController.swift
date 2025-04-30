//
//  JourneySelectionViewController.swift
//  Packing
//
//  Created by 이융의 on 4/30/25.
//

import UIKit
import RxSwift

// MARK: - JOURNEY SELECTION VIEW CONTROLLER

class JourneySelectionViewController: UIViewController {
    
    // MARK: - Properties
    var selectedFriend: Friend!
    private let journeyService = JourneyService()
    private var journeys: [Journey] = []
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 180)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TravelPlanCell.self, forCellWithReuseIdentifier: "TravelPlanCell")
        
        return collectionView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "여행 계획이 없습니다."
        label.textAlignment = .center
        label.textColor = .gray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadJourneys()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "여행 선택"
        
        titleLabel.text = "\(selectedFriend.name)님을 초대할 여행을 선택해주세요"
        
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        collectionView.rx.modelSelected(Journey.self)
            .subscribe(onNext: { [weak self] journey in
                self?.inviteFriendToJourney(journey: journey)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data Loading
    private func loadJourneys() {
        loadingIndicator.startAnimating()
        
        journeyService.getJourneys()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] journeys in
                self?.journeys = journeys
                self?.updateUI()
                self?.loadingIndicator.stopAnimating()
            }, onError: { [weak self] error in
                self?.showErrorAlert(message: error.localizedDescription)
                self?.loadingIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI() {
        emptyLabel.isHidden = !journeys.isEmpty
        
        // Bind journeys to collection view
        Observable.just(journeys)
            .bind(to: collectionView.rx.items(cellIdentifier: "TravelPlanCell", cellType: TravelPlanCell.self)) { index, journey, cell in
                cell.configure(with: journey)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    private func inviteFriendToJourney(journey: Journey) {
        loadingIndicator.startAnimating()
        
        journeyService.inviteParticipant(journeyId: journey.id, email: selectedFriend.email)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                self?.loadingIndicator.stopAnimating()
                self?.showSuccessAlert(journey: journey)
            }, onError: { [weak self] error in
                self?.loadingIndicator.stopAnimating()
                self?.showErrorAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Alerts
    private func showSuccessAlert(journey: Journey) {
        let alert = UIAlertController(
            title: "초대 완료",
            message: "\(selectedFriend.name)님을 '\(journey.title)' 여행에 초대했습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        present(alert, animated: true)
    }
}
