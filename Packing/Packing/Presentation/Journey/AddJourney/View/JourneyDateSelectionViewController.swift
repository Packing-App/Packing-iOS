//
//  JourneyDateSelectionViewController.swift
//  Packing
//
//  Created by 이융의 on 4/14/25.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class JourneyDateSelectionViewController: UIViewController, View {
    
    // MARK: - Properties
    typealias Reactor = JourneyDateSelectionReactor
    
    var disposeBag = DisposeBag()
    
    private lazy var navigationTitleLabel: UILabel = {
        let label = UILabel()
        let attachmentString = NSMutableAttributedString(string: "")
        let imageAttachment: NSTextAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "logoIconWhite")
        let isSmallDevice = UIScreen.main.bounds.height < 700
        let iconSize: CGFloat = isSmallDevice ? 20 : 24
        imageAttachment.bounds = CGRect(x: 0, y: -6, width: iconSize, height: iconSize)
        attachmentString.append(NSAttributedString(attachment: imageAttachment))
        attachmentString.append(NSAttributedString(string: " PACKING"))
        label.attributedText = attachmentString
        label.sizeToFit()
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: isSmallDevice ? 18 : 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let planProgressBar: PlanProgressBar = {
        let progressBar = PlanProgressBar(progress: 1)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        return progressBar
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "여행 정보를 입력해주세요"
        let isSmallDevice = UIScreen.main.bounds.height < 700
        label.font = UIFont.systemFont(ofSize: isSmallDevice ? 16 : 17, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let departureButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Use UIButtonConfiguration for iOS 15+ compatibility
        var config = UIButton.Configuration.plain()
        config.title = "어디서 출발하시나요?"
        config.baseForegroundColor = .gray
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 0)
        config.background.backgroundColor = .white
        button.configuration = config
        
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let planeImage = UIImage(systemName: "airplane.departure")
        let imageView = UIImageView(image: planeImage)
        imageView.tintColor = UIColor.main
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 15),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return button
    }()
    
    private let destinationButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Use UIButtonConfiguration for iOS 15+ compatibility
        var config = UIButton.Configuration.plain()
        config.title = "어디로 떠나시나요?"
        config.baseForegroundColor = .gray
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 0)
        config.background.backgroundColor = .white
        button.configuration = config
        
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let planeImage = UIImage(systemName: "airplane.arrival")
        let imageView = UIImageView(image: planeImage)
        imageView.tintColor = UIColor.main
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 15),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return button
    }()
    
    private let dateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let departureDateButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.title = "출발 날짜"
        config.baseForegroundColor = .black
        config.background.backgroundColor = .white
        button.configuration = config
        
        let isSmallDevice = UIScreen.main.bounds.height < 700
        button.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 10 : 12)
        button.tintColor = .gray
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let arrivalDateButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.title = "도착 날짜"
        config.baseForegroundColor = .black
        config.background.backgroundColor = .white
        button.configuration = config
        
        let isSmallDevice = UIScreen.main.bounds.height < 700
        button.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 10 : 12)
        button.tintColor = .gray
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let monthControlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let previousMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.text = "2024년 5월"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let calendarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let weekdaysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = "다음"
        config.baseForegroundColor = .white
        config.background.backgroundColor = .black
        config.cornerStyle = .medium
        button.configuration = config
        
        let isSmallDevice = UIScreen.main.bounds.height < 700
        button.titleLabel?.font = UIFont.systemFont(ofSize: isSmallDevice ? 15 : 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var calendarDayButtons = [UIButton]()
    private var selectedDepartureDate: Date?
    private var selectedArrivalDate: Date?
    private var currentMonth = Date()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCalendar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor?.action.onNext(.viewDidAppear)
    }
    
    func bind(reactor: Reactor) {
        // Action
        // 출발지 선택 버튼 탭 처리
        departureButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showOriginSearch()
            })
            .disposed(by: disposeBag)
        
        // 도착지 선택 버튼 탭 처리
        destinationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showDestinationSearch()
            })
            .disposed(by: disposeBag)
        
        // 날짜 선택 처리
        previousMonthButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.moveToPreviousMonth()
            })
            .disposed(by: disposeBag)
        
        nextMonthButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.moveToNextMonth()
            })
            .disposed(by: disposeBag)
        
        // 다음 버튼 탭 처리
        nextButton.rx.tap
            .map { Reactor.Action.next }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        // 출발지 업데이트
        reactor.state.map { $0.origin }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] origin in
                var config = self?.departureButton.configuration
                config?.title = origin.isEmpty ? "어디서 출발하시나요?" : origin
                config?.baseForegroundColor = origin.isEmpty ? .gray : .black
                self?.departureButton.configuration = config
            })
            .disposed(by: disposeBag)
        
        // 도착지 업데이트
        reactor.state.map { $0.destination }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] destination in
                var config = self?.destinationButton.configuration
                config?.title = destination.isEmpty ? "어디로 떠나시나요?" : destination
                config?.baseForegroundColor = destination.isEmpty ? .gray : .black
                self?.destinationButton.configuration = config
            })
            .disposed(by: disposeBag)
        
        // 날짜 업데이트
        Observable.combineLatest(
            reactor.state.map { $0.startDate },
            reactor.state.map { $0.endDate }
        )
        .observe(on: MainScheduler.instance)
        .distinctUntilChanged { prev, next in
            return prev.0?.timeIntervalSince1970 == next.0?.timeIntervalSince1970 &&
                   prev.1?.timeIntervalSince1970 == next.1?.timeIntervalSince1970
        }
        .subscribe(onNext: { [weak self] startDate, endDate in
            self?.updateDates(startDate: startDate, endDate: endDate)
        })
        .disposed(by: disposeBag)
        
        // 다음 버튼 활성화 상태 업데이트
        reactor.state.map { $0.canProceed }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] canProceed in
                var config = self?.nextButton.configuration
                config?.background.backgroundColor = canProceed ? .black : .lightGray
                self?.nextButton.configuration = config
                self?.nextButton.isEnabled = canProceed
            })
            .disposed(by: disposeBag)
        
        // 오류 메시지 표시
        reactor.state.map { $0.errorMessage }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showAlert(message: errorMessage)
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Methods
    private func showOriginSearch() {
        let searchVC = LocationSearchViewController(searchType: .departure)
        searchVC.completion = { [weak self] location in
            self?.reactor?.action.onNext(.setOrigin(location))
        }
        
        if let sheet = searchVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(searchVC, animated: true)
    }
    
    private func showDestinationSearch() {
        let searchVC = LocationSearchViewController(searchType: .destination)
        searchVC.completion = { [weak self] location in
            self?.reactor?.action.onNext(.setDestination(location))
        }
        
        if let sheet = searchVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(searchVC, animated: true)
    }
    
    private func moveToPreviousMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            setupCalendar()
        }
    }
    
    private func moveToNextMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            setupCalendar()
        }
    }
    
    private func updateDates(startDate: Date?, endDate: Date?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        
        selectedDepartureDate = startDate
        selectedArrivalDate = endDate
        
        if let departureDate = startDate {
            var config = departureDateButton.configuration
            config?.title = "출발 \(dateFormatter.string(from: departureDate))"
            departureDateButton.configuration = config
        } else {
            var config = departureDateButton.configuration
            config?.title = "출발 날짜 선택"
            departureDateButton.configuration = config
        }
        
        if let arrivalDate = endDate {
            var config = arrivalDateButton.configuration
            config?.title = "도착 \(dateFormatter.string(from: arrivalDate))"
            arrivalDateButton.configuration = config
        } else {
            var config = arrivalDateButton.configuration
            config?.title = "도착 날짜 선택"
            arrivalDateButton.configuration = config
        }
        
        highlightSelectedDates()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Setup UI & Calendar
    private func setupUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navigationTitleLabel)

        view.backgroundColor = .systemGray6
        
        // 디바이스 크기에 따른 조정
        let isSmallDevice = UIScreen.main.bounds.height < 700
        let containerHeight: CGFloat = isSmallDevice ? 450 : 560
        
        // Add progress bar
        view.addSubview(planProgressBar)

        // Add container view
        view.addSubview(containerView)
        
        // Add components to container
        containerView.addSubview(titleLabel)
        containerView.addSubview(departureButton)
        containerView.addSubview(destinationButton)
        containerView.addSubview(dateStackView)
        
        // Add date buttons to stack
        dateStackView.addArrangedSubview(departureDateButton)
        dateStackView.addArrangedSubview(arrivalDateButton)
        
        // Add month control
        containerView.addSubview(monthControlStackView)
        monthControlStackView.addArrangedSubview(previousMonthButton)
        monthControlStackView.addArrangedSubview(monthYearLabel)
        monthControlStackView.addArrangedSubview(nextMonthButton)
        
        // Add calendar view
        containerView.addSubview(calendarView)
        
        // Add weekdays stack
        containerView.addSubview(weekdaysStackView)
        setupWeekdaysLabels()
        
        // Add next button
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            // Progress bar constraints
            planProgressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            planProgressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            planProgressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            planProgressBar.heightAnchor.constraint(equalToConstant: isSmallDevice ? 15 : 20),
            
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: planProgressBar.bottomAnchor, constant: 30),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: containerHeight),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: isSmallDevice ? 15 : 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Departure button constraints
            departureButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: isSmallDevice ? 15 : 20),
            departureButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            departureButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            departureButton.heightAnchor.constraint(equalToConstant: isSmallDevice ? 40 : 45),
            
            // Destination button constraints
            destinationButton.topAnchor.constraint(equalTo: departureButton.bottomAnchor, constant: isSmallDevice ? 8 : 10),
            destinationButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            destinationButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            destinationButton.heightAnchor.constraint(equalToConstant: isSmallDevice ? 40 : 45),
            
            // Date stack view constraints
            dateStackView.topAnchor.constraint(equalTo: destinationButton.bottomAnchor, constant: isSmallDevice ? 10 : 15),
            dateStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            dateStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            dateStackView.heightAnchor.constraint(equalToConstant: isSmallDevice ? 35 : 40),
            
            // Month control stack view constraints
            monthControlStackView.topAnchor.constraint(equalTo: dateStackView.bottomAnchor, constant: isSmallDevice ? 15 : 20),
            monthControlStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            monthControlStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            monthControlStackView.heightAnchor.constraint(equalToConstant: isSmallDevice ? 25 : 30),
            
            // Weekdays stack view constraints
            weekdaysStackView.topAnchor.constraint(equalTo: monthControlStackView.bottomAnchor, constant: isSmallDevice ? 10 : 15),
            weekdaysStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            weekdaysStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            weekdaysStackView.heightAnchor.constraint(equalToConstant: isSmallDevice ? 25 : 30),
            
            // Calendar view constraints
            calendarView.topAnchor.constraint(equalTo: weekdaysStackView.bottomAnchor, constant: isSmallDevice ? 5 : 10),
            calendarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            calendarView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -15),
            
            // Next button constraints
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: isSmallDevice ? 45 : 50)
        ])
    }
    
    private func setupWeekdaysLabels() {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let isSmallDevice = UIScreen.main.bounds.height < 700

        for weekday in weekdays {
            let label = UILabel()
            label.text = weekday
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: isSmallDevice ? 12 : 14)
            
            if weekday == "일" {
                label.textColor = .systemRed
            } else {
                label.textColor = .darkGray
            }
            
            weekdaysStackView.addArrangedSubview(label)
        }
    }
    
    private func setupCalendar() {
        // Clear any existing calendar buttons
        for button in calendarDayButtons {
            button.removeFromSuperview()
        }
        calendarDayButtons.removeAll()
        
        // Get the current month's calendar info
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentMonth)
        let currentMonthInt = calendar.component(.month, from: currentMonth)
        
        // Update month label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        monthYearLabel.text = dateFormatter.string(from: currentMonth)
        
        // Calculate days in month and first weekday
        let dateComponents = DateComponents(year: currentYear, month: currentMonthInt)
        guard let firstDayOfMonth = calendar.date(from: dateComponents),
              let rangeOfDays = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return
        }
        
        let numberOfDays = rangeOfDays.count
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1 // 0-based index for our grid
        
        // Create a calendar grid with adaptive button sizes
        let isSmallDevice = UIScreen.main.bounds.height < 700
        
        // 강제로 레이아웃 업데이트하여 실제 너비 확보
        calendarView.layoutIfNeeded()
        
        // 버튼 너비는 요일 칼럼과 일치하도록 계산
        let buttonWidth: CGFloat = (calendarView.bounds.width > 0 ? calendarView.bounds.width : UIScreen.main.bounds.width - 80) / 7
        
        // 버튼 높이는 너비보다 작게 설정하여 세로 간격 감소
        let buttonHeight: CGFloat = isSmallDevice ? buttonWidth * 0.8 : buttonWidth * 0.9
        
        let rows = 6 // Max number of rows needed for any month
        
        for row in 0..<rows {
            for col in 0..<7 {
                let index = row * 7 + col
                let dayNumber = index - firstWeekday + 1
                
                let button = UIButton(type: .system)
                button.frame = CGRect(
                    x: CGFloat(col) * buttonWidth,
                    y: CGFloat(row) * buttonHeight,
                    width: buttonWidth - 4,
                    height: buttonHeight - 4
                )
                
                // Configure button appearance
                let fontSize: CGFloat = isSmallDevice ? 12 : 14
                button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
                button.layer.cornerRadius = buttonHeight / 2.4
                button.tag = dayNumber
                
                if dayNumber > 0 && dayNumber <= numberOfDays {
                    button.setTitle("\(dayNumber)", for: .normal)
                    button.addTarget(self, action: #selector(calendarDayTapped(_:)), for: .touchUpInside)
                    button.setTitleColor(.black, for: .normal)
                    
                    // Highlight current day
                    if calendar.isDateInToday(calendar.date(byAdding: .day, value: dayNumber - 1, to: firstDayOfMonth) ?? Date()) {
                        button.layer.borderWidth = 1
                        button.layer.borderColor = UIColor.main.cgColor
                    }
                } else {
                    // Empty days
                    button.setTitle("", for: .normal)
                    button.isEnabled = false
                }
                
                calendarView.addSubview(button)
                calendarDayButtons.append(button)
            }
        }
        // Highlight selected dates
        highlightSelectedDates()
    }
    
    @objc private func calendarDayTapped(_ sender: UIButton) {
        // Get the day from the button tag
        let dayNumber = sender.tag
        
        // Create the selected date
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentMonth)
        let month = calendar.component(.month, from: currentMonth)
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = dayNumber
        
        guard let selectedDate = calendar.date(from: dateComponents) else { return }
        
        // If we don't have departure date yet, or if we're starting a new selection
        if selectedDepartureDate == nil || (selectedDepartureDate != nil && selectedArrivalDate != nil) {
            // Reset selection
            selectedDepartureDate = selectedDate
            selectedArrivalDate = nil
            
            // Update Reactor state
            reactor?.action.onNext(.setStartDate(selectedDate))
        }
        // If we have a departure date but no arrival date
        else if selectedArrivalDate == nil {
            // If the selected date is before the departure date, swap them
            if selectedDate < selectedDepartureDate! {
                selectedArrivalDate = selectedDepartureDate
                selectedDepartureDate = selectedDate
                
                // Update Reactor state
                reactor?.action.onNext(.setDates(start: selectedDate, end: selectedArrivalDate!))
            } else {
                selectedArrivalDate = selectedDate
                
                // Update Reactor state
                reactor?.action.onNext(.setDates(start: selectedDepartureDate!, end: selectedDate))
            }
        }
    }
    
    private func highlightSelectedDates() {
        // Reset all buttons
        for button in calendarDayButtons {
            if button.isEnabled {
                button.backgroundColor = .clear
                button.setTitleColor(.black, for: .normal)
                button.layer.borderWidth = 0
            }
        }
        
        // Highlight departure and arrival dates
        let calendar = Calendar.current
        
        if let departureDate = selectedDepartureDate {
            highlightDate(departureDate, withColor: UIColor.main)
        }
        
        if let arrivalDate = selectedArrivalDate {
            highlightDate(arrivalDate, withColor: UIColor.main)
            
            // Highlight days in between
            if let departure = selectedDepartureDate {
                var currentDate = departure
                while currentDate < arrivalDate {
                    if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                        if nextDate < arrivalDate {
                            highlightDate(nextDate, withColor: UIColor.main.withAlphaComponent(0.4))
                        }
                        currentDate = nextDate
                    } else {
                        break
                    }
                }
            }
        }
    }
    
    private func highlightDate(_ date: Date, withColor color: UIColor) {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let currentMonth = calendar.component(.month, from: self.currentMonth)
        
        // Only highlight if the date is in the current displayed month
        if month == currentMonth {
            for button in calendarDayButtons {
                if button.tag == day {
                    button.backgroundColor = color
                    button.setTitleColor(.white, for: .normal)
                    // make bold font
                    let isSmallDevice = UIScreen.main.bounds.height < 700
                    let fontSize: CGFloat = isSmallDevice ? 12 : 14
                    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
                    break
                }
            }
        }
    }
}
