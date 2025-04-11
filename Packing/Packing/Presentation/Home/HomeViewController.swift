//
//  HomeViewController.swift
//  Packing
//
//  Created by 이융의 on 3/29/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - UI COMPONENTS
    
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
    
    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.preferredSymbolConfiguration = .init(pointSize: 18, weight: .regular)
        
        return button
    }()
    
    private lazy var planeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "plane"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var planeCloudImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "planeCloud"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var planeCloudTwoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "planeCloud2"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.text = "라라님!\n여행 준비를 같이 해볼까요?"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addNewJourneyButton: UIButton = {
        let button = UIButton()
        
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .black.withAlphaComponent(0.85)
        configuration.baseBackgroundColor = .white.withAlphaComponent(0.75)
        configuration.buttonSize = .large
        configuration.title = "새로운 여행 준비하기"
        
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        
        button.configuration = configuration
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.5
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // My Travel Plan
    private lazy var myTravelPlansView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var myTravelPlansLabel: UILabel = {
        let label = UILabel()
        label.text = "라라님의 여행 계획"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("더보기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.gray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var travelPlansCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 180, height: 180)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TravelPlanCell.self, forCellWithReuseIdentifier: "TravelPlanCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    
    // Templates Section
    private lazy var templatesSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "테마별 여행 준비물 모음"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var templatesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let itemWidth = (UIScreen.main.bounds.width - 60) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 30)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TemplateCell.self, forCellWithReuseIdentifier: "TemplateCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private var gradientLayer: CAGradientLayer!
    
    // MARK: - DATA
    
    private let travelPlans = Journey.exampleJourneys
    
    private let themeTemplates = [
        TravelThemeTemplate(themeName: "수상 스포츠", image: "waterSports"),
        TravelThemeTemplate(themeName: "자전거 타기", image: "cycling"),
        TravelThemeTemplate(themeName: "캠핑", image: "camping"),
        TravelThemeTemplate(themeName: "피크닉", image: "picnic"),
        TravelThemeTemplate(themeName: "등산", image: "hiking"),
        TravelThemeTemplate(themeName: "스키", image: "skiing"),
        TravelThemeTemplate(themeName: "낚시", image: "fishing"),
        TravelThemeTemplate(themeName: "쇼핑", image: "shopping"),
        TravelThemeTemplate(themeName: "테마파크", image: "themepark")
    ]
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureNavigationBar()
        setupGradientBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frame when view layout changes
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - SETUP
    
    private func setupUI() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: navigationTitleLabel)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: notificationButton)
        
        view.addSubview(planeImageView)
        view.addSubview(planeCloudImageView)
        view.addSubview(titleLabel)
        view.addSubview(planeCloudTwoImageView)
        view.addSubview(addNewJourneyButton)
        view.addSubview(myTravelPlansView)
        myTravelPlansView.addSubview(myTravelPlansLabel)
        myTravelPlansView.addSubview(seeAllButton)
        myTravelPlansView.addSubview(travelPlansCollectionView)
        view.addSubview(templatesSectionLabel)
        view.addSubview(templatesCollectionView)
        
        NSLayoutConstraint.activate([
            planeImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            planeImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            planeImageView.widthAnchor.constraint(equalToConstant: 80),
            planeImageView.heightAnchor.constraint(equalToConstant: 40),
            
            planeCloudImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            planeCloudImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            planeCloudImageView.widthAnchor.constraint(equalToConstant: 80),
            planeCloudImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: planeImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            planeCloudTwoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            planeCloudTwoImageView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10),
            planeCloudTwoImageView.widthAnchor.constraint(equalToConstant: 50),
            planeCloudTwoImageView.heightAnchor.constraint(equalToConstant: 20),
            
            addNewJourneyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addNewJourneyButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            addNewJourneyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            addNewJourneyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            myTravelPlansView.topAnchor.constraint(equalTo: addNewJourneyButton.bottomAnchor, constant: 40),
            myTravelPlansView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            myTravelPlansView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            
            myTravelPlansLabel.topAnchor.constraint(equalTo: myTravelPlansView.topAnchor, constant: 20),
            myTravelPlansLabel.leadingAnchor.constraint(equalTo: myTravelPlansView.leadingAnchor, constant: 20),
            
            seeAllButton.centerYAnchor.constraint(equalTo: myTravelPlansLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: myTravelPlansView.trailingAnchor, constant: -20),
            
            travelPlansCollectionView.topAnchor.constraint(equalTo: myTravelPlansLabel.bottomAnchor, constant: 15),
            travelPlansCollectionView.leadingAnchor.constraint(equalTo: myTravelPlansView.leadingAnchor),
            travelPlansCollectionView.trailingAnchor.constraint(equalTo: myTravelPlansView.trailingAnchor),
            travelPlansCollectionView.heightAnchor.constraint(equalToConstant: 200),
            travelPlansCollectionView.bottomAnchor.constraint(equalTo: myTravelPlansView.bottomAnchor, constant: -10),
            
            templatesSectionLabel.topAnchor.constraint(equalTo: myTravelPlansView.bottomAnchor, constant: 30),
            templatesSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            templatesCollectionView.topAnchor.constraint(equalTo: templatesSectionLabel.bottomAnchor, constant: 15),
            templatesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            templatesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            templatesCollectionView.heightAnchor.constraint(equalToConstant: 450),
            
        ])
    }
    
    private func setupGradientBackground() {
        // Create gradient layer
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.main.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.2)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.frame = view.bounds
        
        // Add gradient as the bottom-most layer
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func configureNavigationBar() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .main
        
        appearance.shadowColor = .clear
        
        // Apply the appearance to all navigation bar states
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == travelPlansCollectionView {
            return travelPlans.count
        } else {
            return themeTemplates.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == travelPlansCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TravelPlanCell", for: indexPath) as! TravelPlanCell
            cell.configure(with: travelPlans[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TemplateCell", for: indexPath) as! TemplateCell
            cell.configure(with: themeTemplates[indexPath.item])
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle selection
    }
}

// MARK: - Custom Cells
class TravelPlanCell: UICollectionViewCell {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with plan: Journey) {
        imageView.image = UIImage(named: plan.imageUrl)
        titleLabel.text = plan.title
        dateLabel.text = plan.startDate
    }
}

class TemplateCell: UICollectionViewCell {
    private let circleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        view.layer.cornerRadius = 50
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(circleView)
        circleView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 100),
            circleView.heightAnchor.constraint(equalToConstant: 100),
            
            imageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with template: TravelThemeTemplate) {
        imageView.image = UIImage(named: template.image)
        titleLabel.text = template.themeName
    }
}


#Preview {
    let homeViewController = HomeViewController()
    let navigationViewController = UINavigationController(rootViewController: homeViewController)
    return navigationViewController
}

//
// Extensions.swift
//

import UIKit

// Add these extensions to your project

// MARK: - UIColor Extension
extension UIColor {
    
    // Useful for theme colors
    static let accentColor = UIColor(red: 255/255, green: 99/255, blue: 99/255, alpha: 1.0)
    static let background = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0)
    static let textPrimary = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
    static let textSecondary = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0)
}

// MARK: - UIView Extension for Shadows
extension UIView {
    func applyShadow(color: UIColor = .black, opacity: Float = 0.1, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    func roundCorners(radius: CGFloat = 8) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}

// MARK: - UIButton Extension
extension UIButton {
    func applyPrimaryStyle(title: String) {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = .main
        configuration.buttonSize = .large
        configuration.title = title
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        
        self.configuration = configuration
        self.applyShadow()
    }
    
    func applySecondaryStyle(title: String) {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = .white.withAlphaComponent(0.25)
        configuration.buttonSize = .large
        configuration.title = title
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        
        self.configuration = configuration
        self.applyShadow()
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func withRoundedCorners(radius: CGFloat = 8) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        context?.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
        context?.clip()
        
        draw(in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

//
//  ScrollViewImplementation.swift
//  Packing
//

import UIKit

// Add this code to make the entire view scrollable

extension HomeViewController {
    
    func setupScrollView() {
        // Create a scroll view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a content view to hold all content
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add scroll view to main view (after setting up gradient)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configure scroll view constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Add all your UI elements to contentView instead of view
        // Move existing constraints to reference contentView instead of view
        
        contentView.addSubview(planeImageView)
        contentView.addSubview(planeCloudImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(planeCloudTwoImageView)
        contentView.addSubview(addNewJourneyButton)
        contentView.addSubview(myTravelPlansView)
        contentView.addSubview(templatesSectionLabel)
        contentView.addSubview(templatesCollectionView)
        
        // Update constraints to reference contentView
        NSLayoutConstraint.activate([
            planeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            planeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            planeImageView.widthAnchor.constraint(equalToConstant: 80),
            planeImageView.heightAnchor.constraint(equalToConstant: 40),
            
            planeCloudImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            planeCloudImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            planeCloudImageView.widthAnchor.constraint(equalToConstant: 80),
            planeCloudImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: planeImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            planeCloudTwoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            planeCloudTwoImageView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10),
            planeCloudTwoImageView.widthAnchor.constraint(equalToConstant: 50),
            planeCloudTwoImageView.heightAnchor.constraint(equalToConstant: 20),
            
            addNewJourneyButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addNewJourneyButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            addNewJourneyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            addNewJourneyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            myTravelPlansView.topAnchor.constraint(equalTo: addNewJourneyButton.bottomAnchor, constant: 40),
            myTravelPlansView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            myTravelPlansView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            templatesSectionLabel.topAnchor.constraint(equalTo: myTravelPlansView.bottomAnchor, constant: 30),
            templatesSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            templatesCollectionView.topAnchor.constraint(equalTo: templatesSectionLabel.bottomAnchor, constant: 15),
            templatesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            templatesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            templatesCollectionView.heightAnchor.constraint(equalToConstant: 450),
            
            // Important: Make sure content view's bottom constraint connects to the last element
            contentView.bottomAnchor.constraint(equalTo: templatesCollectionView.bottomAnchor, constant: 30)
        ])
    }
}


//
//  AnimationEffects.swift
//  Packing
//

import UIKit

// Add these animations to enhance the user experience

extension HomeViewController {
    
    // Call this in viewDidAppear
    func animateHeaderElements() {
        // Initially set alpha to 0 for elements to animate
        planeImageView.alpha = 0
        planeCloudImageView.alpha = 0
        planeCloudTwoImageView.alpha = 0
        titleLabel.alpha = 0
        addNewJourneyButton.alpha = 0
        
        // Animate plane flying in
        UIView.animate(withDuration: 1.0, delay: 0.2, options: [.curveEaseOut], animations: {
            self.planeImageView.alpha = 1
            self.planeImageView.transform = CGAffineTransform(translationX: -20, y: 0)
        })
        
        // Animate clouds appearing
        UIView.animate(withDuration: 0.8, delay: 0.4, options: [.curveEaseOut], animations: {
            self.planeCloudImageView.alpha = 1
        })
        
        UIView.animate(withDuration: 0.8, delay: 0.5, options: [.curveEaseOut], animations: {
            self.planeCloudTwoImageView.alpha = 1
        })
        
        // Animate title appearing
        UIView.animate(withDuration: 0.8, delay: 0.6, options: [.curveEaseOut], animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -10)
        })
        
        // Animate button appearing
        UIView.animate(withDuration: 0.8, delay: 0.8, options: [.curveEaseOut], animations: {
            self.addNewJourneyButton.alpha = 1
            self.addNewJourneyButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.addNewJourneyButton.transform = .identity
            })
        })
    }
    
    // Call this when setting up UI
    func setupCloudAnimation() {
        // Setup repeated cloud animation
        let cloudAnimation = CABasicAnimation(keyPath: "position.x")
        cloudAnimation.fromValue = planeCloudTwoImageView.layer.position.x - 10
        cloudAnimation.toValue = planeCloudTwoImageView.layer.position.x + 10
        cloudAnimation.duration = 3.0
        cloudAnimation.repeatCount = .infinity
        cloudAnimation.autoreverses = true
        cloudAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        planeCloudTwoImageView.layer.add(cloudAnimation, forKey: "floatingCloud")
    }
    
    // Make the Add Journey button pulse to draw attention
    func setupAddButtonPulse() {
        let pulseAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 0.6
        pulseAnimation.duration = 1.2
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.autoreverses = true
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        addNewJourneyButton.layer.add(pulseAnimation, forKey: "pulseAnimation")
    }
    
    // Add reactive button feedback
    func setupButtonFeedback() {
        addNewJourneyButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        addNewJourneyButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    // Add to viewDidLoad
    func setupAllAnimations() {
        // Setup initial states
        planeImageView.alpha = 0
        planeCloudImageView.alpha = 0
        planeCloudTwoImageView.alpha = 0
        titleLabel.alpha = 0
        addNewJourneyButton.alpha = 0
        
        // Setup animations that will be triggered later
        setupCloudAnimation()
        setupAddButtonPulse()
        setupButtonFeedback()
    }
    
    // Add this to your class
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateHeaderElements()
    }
}
