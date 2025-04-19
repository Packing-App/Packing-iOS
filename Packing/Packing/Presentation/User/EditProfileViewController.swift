//
//  EditProfileViewController.swift
//  Packing
//
//  Created by 이융의 on 4/19/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class EditProfileViewController: UIViewController, View {
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let changeImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("사진 변경", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름을 입력하세요"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.text = "소개"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let introTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.cornerRadius = 5
        textView.font = .systemFont(ofSize: 14)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let imagePicker = UIImagePickerController()
    
    // MARK: - Initializers
    init(reactor: EditProfileViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupImagePicker()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "프로필 수정"
        view.backgroundColor = .systemBackground
        
        // 네비게이션 바 설정
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        // UI 컴포넌트 추가
        view.addSubview(profileImageView)
        view.addSubview(changeImageButton)
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(introLabel)
        view.addSubview(introTextView)
        view.addSubview(saveButton)
        view.addSubview(loadingIndicator)
        
        // 제약 조건 설정
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            changeImageButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            changeImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: changeImageButton.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            introLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            introLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            introLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            introTextView.topAnchor.constraint(equalTo: introLabel.bottomAnchor, constant: 8),
            introTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            introTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            introTextView.heightAnchor.constraint(equalToConstant: 120),
            
            saveButton.topAnchor.constraint(equalTo: introTextView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
    }
    
    @objc private func cancelButtonTapped() {
        reactor?.action.onNext(.cancel)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - ReactorKit Binding
    func bind(reactor: EditProfileViewReactor) {
        // 초기 이미지 설정
        if let imageURL = reactor.currentState.profileImageUrl, !imageURL.isEmpty {
            if let image = UIImage(named: imageURL) {
                profileImageView.image = image
            } else {
                // URL에서 이미지 로드 (실제 앱에서는 캐싱 라이브러리 사용 권장)
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        // Action 바인딩
        nameTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.updateName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        introTextView.rx.text.orEmpty
            .distinctUntilChanged()
            .map { Reactor.Action.updateIntro($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .map { Reactor.Action.save }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        changeImageButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.presentImagePicker()
            })
            .disposed(by: disposeBag)
        
        // State 바인딩
        reactor.state.map { $0.name }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: nameTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.intro }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: introTextView.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isValid }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.saveButton.isEnabled = false
                } else {
                    self?.loadingIndicator.stopAnimating()
                    if let isValid = self?.reactor?.currentState.isValid {
                        self?.saveButton.isEnabled = isValid
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.error }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isSaveComplete }
            .observe(on: MainScheduler.instance)
            .filter { $0 }
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 프로필 이미지 업데이트
        reactor.state.map { $0.profileImageUrl }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] imageUrl in
                // 실제 앱에서는 이미지 로딩 라이브러리 사용
                // self?.profileImageView.kf.setImage(with: URL(string: imageUrl))
                self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
            })
            .disposed(by: disposeBag)
    }
    
    private func presentImagePicker() {
        present(imagePicker, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            profileImageView.image = image
            reactor?.action.onNext(.updateProfileImage(image))
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
