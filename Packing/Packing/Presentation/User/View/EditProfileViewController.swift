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
import Kingfisher
import Photos

final class EditProfileViewController: UIViewController, View {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private let imagePicker = UIImagePickerController()
    
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
        button.setTitle("사진 변경".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름".localized
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름을 입력하세요".localized
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.text = "소개".localized
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
        button.setTitle("저장".localized, for: .normal)
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
        setupKeyboardHandling()
        updateUIWithInitialValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIWithInitialValues()
        
//        setupNavigationBarAppearance()
    }
    
    // 화면 해제 시 노티피케이션 제거
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "프로필 수정".localized
        view.backgroundColor = .systemBackground
        
        // 네비게이션 바 설정
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소".localized,
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )

        // 오른쪽에 완료 버튼 추가
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "완료".localized,
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
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
        
        setupConstraints()
    }
    
    private func setupConstraints() {
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
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        // 네비게이션 바에 적용
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
    }
    
    private func setupKeyboardHandling() {
        // 탭 제스처로 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // 텍스트필드 delegate 설정
        nameTextField.delegate = self
        
        // 키보드 노티피케이션 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func updateUIWithInitialValues() {
        guard let reactor = self.reactor else { return }
        
        // 강제로 텍스트 필드에 값 할당
        DispatchQueue.main.async { [weak self] in
            self?.nameTextField.text = reactor.currentState.name
            self?.introTextView.text = reactor.currentState.intro
        }
        
        // 프로필 이미지 설정
        if let imageURL = reactor.currentState.profileImageUrl, !imageURL.isEmpty {
            if let url = URL(string: imageURL) {
                profileImageView.kf.setImage(with: url)
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    // MARK: - Photo Library Permission
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            presentImagePicker()
        case .denied, .restricted:
            showPhotoLibraryPermissionDeniedAlert()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        self?.presentImagePicker()
                    } else {
                        self?.showPhotoLibraryPermissionDeniedAlert()
                    }
                }
            }
        @unknown default:
            break
        }
    }
    
    private func showPhotoLibraryPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "사진 접근 권한 필요".localized,
            message: "프로필 사진을 변경하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.".localized,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "설정으로 이동".localized, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "취소".localized, style: .cancel))
        present(alert, animated: true)
    }
    
    private func presentImagePicker() {
        present(imagePicker, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인".localized, style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        reactor?.action.onNext(.cancel)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        reactor?.action.onNext(.save)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if introTextView.isFirstResponder {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                
                let activeRect = introTextView.convert(introTextView.bounds, to: view)
                let keyboardOverlap = activeRect.maxY - (view.bounds.height - keyboardSize.height)
                
                if keyboardOverlap > 0 {
                    view.frame.origin.y = -keyboardOverlap
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    // MARK: - ReactorKit Binding
    func bind(reactor: EditProfileViewReactor) {
        // 초기 UI 설정
        nameTextField.text = reactor.currentState.name
        introTextView.text = reactor.currentState.intro
        
        // Action 바인딩
        nameTextField.rx.text.orEmpty
            .skip(1)
            .distinctUntilChanged()
            .map { Reactor.Action.updateName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        introTextView.rx.text.orEmpty
            .skip(1)
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
                self?.checkPhotoLibraryPermission()
            })
            .disposed(by: disposeBag)
        
        // State 바인딩
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
        
        reactor.state.map { $0.profileImageUrl }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] imageUrl in
                if let url = URL(string: imageUrl) {
                    self?.profileImageView.kf.setImage(with: url)
                } else {
                    self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                }
            })
            .disposed(by: disposeBag)
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

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == nameTextField {
            introTextView.becomeFirstResponder()
        }
        
        return true
    }
}
