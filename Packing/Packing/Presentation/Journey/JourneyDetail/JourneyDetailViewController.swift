//
//  JourneyDetailViewController.swift
//  Packing
//
//  Created by 이융의 on 4/12/25.
//

import UIKit
import SwiftUI
import RxSwift

// MARK: - UI 상수 정의
fileprivate struct UIConstants {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 10
    static let cornerRadius: CGFloat = 20
    static let minTapTargetSize: CGFloat = 44
    static let imageHeight: CGFloat = 220
}

// MARK: - JourneyDetailViewController
class JourneyDetailViewController: UIViewController {
    
    // Properties
    var journey: Journey?
    private var hostingController: UIHostingController<JourneyDetailView>?
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        // Reset navigation bar appearance
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
        } else {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil
            navigationController?.navigationBar.isTranslucent = true
            navigationController?.navigationBar.barTintColor = nil
            navigationController?.navigationBar.backgroundColor = nil
        }
        navigationController?.navigationBar.tintColor = .systemBlue
        
        
        let deleteButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteJourneyTapped)
        )
        deleteButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = deleteButton
    }
    
    // Setup
    private func setupUI() {
        // Ensure we have a journey
        guard let journey = journey else { return }
        
        // Create the SwiftUI view
        let journeyDetailView = JourneyDetailView(journey: journey)
        
        // Create and setup hosting controller
        let hostingController = UIHostingController(rootView: journeyDetailView)
        self.hostingController = hostingController
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    // 삭제 액션 메서드
    @objc private func deleteJourneyTapped() {
        // 확인 알림 표시
        let alert = UIAlertController(
            title: "여행 삭제",
            message: "이 여행을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self = self, let journey = self.journey else { return }
            
            self.deleteJourney(id: journey.id)
        })
        
        present(alert, animated: true)
    }
    
    private func deleteJourney(id: String) {
        let loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(loadingView)
        
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = loadingView.center
        loadingIndicator.color = .white
        loadingIndicator.startAnimating()
        loadingView.addSubview(loadingIndicator)
        
        // JourneyService 인스턴스 생성 및 삭제 요청
        let journeyService = JourneyService()
        
        Task {
            do {
                _ = try await journeyService.deleteJourney(id: id)
                
                await MainActor.run {
                    loadingView.removeFromSuperview()
                    // 삭제 성공 시 이전 화면으로 돌아가기
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    loadingView.removeFromSuperview()
                    // 오류 알림 표시
                    let errorAlert = UIAlertController(
                        title: "오류",
                        message: "여행을 삭제하는데 실패했습니다: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
        }
    }
    
}

// MARK: - JourneyDetailView

struct JourneyDetailView: View {
    // Properties
    let journey: Journey
    @State private var packingItems: [PackingItem] = []
    @State private var selectedTab = 0
    @State private var expandedCategories: Set<ItemCategory> = Set()
    
    @State private var showingAddItemSheet = false
    @State private var showingFullScreenImage = false
    
    // State for API calls
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    // Service
    private let packingService = PackingItemService()
    private let journeyService = JourneyService()
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
             ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        headerSection(screenWidth: geometry.size.width)
                        
                        VStack(spacing: adaptiveSpacing) {
                            journeyInfoSection
                                                        
                            if !journey.isPrivate {
                                Divider()
                                participantsSection
                            }
                            
                            Divider()
                            
                            WeatherSection(journey: journey)
                            
                            Divider()
                            
                            progressSection
                            
                            itemsTabView(screenWidth: geometry.size.width)
                        }
                        .padding(.top, UIConstants.verticalPadding + 14)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                        .offset(y: -20)
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                }
                .refreshable {
                    await refreshPackingItems()
                }
                
                if isLoading && packingItems.isEmpty {
                    loadingOverlay
                }
            }
        }
        .alert(item: Binding(
            get: { errorMessage.map { ErrorWrapper(message: $0) } },
            set: { errorMessage = $0?.message }
        )) { error in
            Alert(
                title: Text("오류"),
                message: Text(error.message),
                dismissButton: .default(Text("확인"))
            )
        }
        .onAppear {
            loadPackingItems()
        }
        .fullScreenCover(isPresented: $showingFullScreenImage) {
            FullScreenImageView(imageUrl: journey.imageUrl, isPresented: $showingFullScreenImage)
        }
    }
    
    // 화면 크기에 따른 간격 조정
    private var adaptiveSpacing: CGFloat {
        horizontalSizeClass == .compact ? 16 : 20
    }
    
    // MARK: - Loading View
    private var loadingOverlay: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.7)
                .blur(radius: 3)
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("준비물 로딩 중...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(UIConstants.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 5)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("준비물을 로딩 중입니다. 잠시만 기다려주세요.")
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Header Section
    private func headerSection(screenWidth: CGFloat) -> some View {
        ZStack(alignment: .top) {
            if let imageUrlString = journey.imageUrl, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Image("defaultTravelImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Image("defaultTravelImage")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(height: min(screenWidth * 0.6, UIConstants.imageHeight))
                .clipped()
            } else {
                Image("defaultTravelImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: min(screenWidth * 0.6, UIConstants.imageHeight))
                    .clipped()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingFullScreenImage = true
        }
    }
    
    // MARK: - Journey Info Section
    private var journeyInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(journey.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(dateRangeText)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.secondary)
                Text("\(journey.origin) → \(journey.destination)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            HStack {
                Image(systemName: transportIcon)
                    .foregroundColor(.secondary)
                Text("이동 수단: \(journey.transportType.displayName)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: themeIcon)
                    .foregroundColor(.secondary)
                Text("테마: \(journey.themes.first!.displayName)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, UIConstants.horizontalPadding)
    }
    
    // MARK: - Participants Section
    private var participantsSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("여행 참가자")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let tabBarController = window.rootViewController as? UITabBarController {
                        
                        DispatchQueue.main.async {
                            tabBarController.selectedIndex = 1
                        }
                    }
                }, label: {
                    Text("초대하기")
                        .font(.subheadline)
                        .foregroundColor(.main)
                })
            }
            .padding(.horizontal, UIConstants.horizontalPadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        // 먼저 일반 참가자들을 뒤에서부터 렌더링
                        let regularParticipants = journey.participants.filter { $0.id != journey.creatorId }
                        ForEach(Array(regularParticipants.enumerated().reversed()), id: \.element.id) { index, participant in
                            ParticipantView(participant: participant, isCreator: false)
                                .offset(x: CGFloat(index + 1) * 30.0) // 방장 뒤에 배치
                        }
                        
                        // 방장을 맨 앞(맨 왼쪽)에 배치
                        if let creator = journey.participants.first(where: { $0.id == journey.creatorId }) {
                            ParticipantView(participant: creator, isCreator: true)
                                .offset(x: 0) // 맨 앞에 배치
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, CGFloat(journey.participants.count - 1) * 30 + 20) // 겹침에 따른 여백 조정
                }
                .padding(.top, 5)
            }
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("준비물 체크")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(checkedItemsCount)/\(packingItems.count)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progressValue)
                .progressViewStyle(LinearProgressViewStyle(tint: .main))
                .frame(height: 8)
        }
        .padding(.horizontal, UIConstants.horizontalPadding)
        .padding(.vertical, 10)
    }
    
    private func itemsTabView(screenWidth: CGFloat) -> some View {
        VStack(spacing: 10) {
            Picker("준비물 유형", selection: $selectedTab) {
                Text("개인 준비물").tag(0)
                Text("공용 준비물").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, UIConstants.horizontalPadding)
            
            TabView(selection: $selectedTab) {
                VStack {
                    packingItemsList(items: personalItems)
                }
                .tag(0)
                
                VStack {
                    packingItemsList(items: sharedItems)
                }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: calculateContentHeight() + UIConstants.verticalPadding * 2)
            
            Button {
                showingAddItemSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("준비물 추가하기")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.main)
                .frame(maxWidth: .infinity)
                .frame(minHeight: UIConstants.minTapTargetSize)
                .background(Color.main.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(.horizontal, UIConstants.horizontalPadding)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingAddItemSheet) {
            AddPackingItemSheet(
                journey: journey,
                onSave: { newItem in
                    packingItems.append(newItem)
                    expandedCategories.insert(newItem.category)
                    selectedTab = newItem.isShared ? 1 : 0
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Packing Items List
    private func packingItemsList(items: [PackingItem]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if items.isEmpty {
                Text(selectedTab == 0 ? "개인 준비물이 없습니다" : "공용 준비물이 없습니다")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                let groupedItems = PackingItem.groupedByCategory(items: items)
                let sortedCategories = groupedItems.keys.sorted { $0.rawValue < $1.rawValue }
                
                ForEach(sortedCategories, id: \.self) { category in
                    if let categoryItems = groupedItems[category] {
                        categorySection(category: category, items: categoryItems)
                    }
                }
            }
        }
        .padding(.horizontal, UIConstants.horizontalPadding)
    }
    
    // MARK: - Category Section with DisclosureGroup
    private func categorySection(category: ItemCategory, items: [PackingItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            DisclosureGroup(
                isExpanded: Binding(
                    get: { expandedCategories.contains(category) },
                    set: { isExpanded in
                        if isExpanded {
                            expandedCategories.insert(category)
                        } else {
                            expandedCategories.remove(category)
                        }
                    }
                ),
                content: {
                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            PackingItemRow(
                                item: item,
                                isSharedTab: selectedTab == 1,
                                onToggle: { isChecked in
                                    toggleItem(item, isChecked: isChecked)
                                },
                                onDelete: {
                                    deleteItem(item)
                                }
                            )
                            .padding(.vertical, 8)
                            
                            if item.id != items.last?.id {
                                Divider()
                                    .padding(.leading, 50)
                            }
                        }
                    }
                    .padding(.top, 8)
                },
                label: {
                    HStack {
                        Image(systemName: categoryIcon(for: category))
                            .foregroundColor(.main)
                            .frame(width: 24, height: 24)
                        
                        Text(category.displayName)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                        
                        Text("\(items.count)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                    .frame(minHeight: UIConstants.minTapTargetSize)
                }
            )
            
            Divider()
        }
    }
    
    // MARK: - API Operations
    
    private func loadPackingItems() {
        isLoading = true
        
        Task {
            do {
                let items = try await packingService.getPackingItemsByJourneyAsync(journeyId: journey.id)
                await MainActor.run {
                    self.packingItems = items
                    setupInitialExpandedCategories()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "준비물을 불러오는데 실패했습니다: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func refreshPackingItems() async {
        do {
            let items = try await packingService.getPackingItemsByJourneyAsync(journeyId: journey.id)
            await MainActor.run {
                self.packingItems = items
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "준비물을 새로고침하는데 실패했습니다: \(error.localizedDescription)"
            }
        }
    }
    
    private func toggleItem(_ item: PackingItem, isChecked: Bool) {
        // 즉시 UI 업데이트를 위한 optimistic update
        if let index = packingItems.firstIndex(where: { $0.id == item.id }) {
            packingItems[index].isChecked = isChecked
        }
        
        // API 호출을 통한 서버 업데이트
        Task {
            do {
                let updatedItem = try await packingService.togglePackingItemAsync(id: item.id)
                await MainActor.run {
                    // 성공 시 서버 응답으로 데이터 업데이트
                    if let index = packingItems.firstIndex(where: { $0.id == updatedItem.id }) {
                        packingItems[index] = updatedItem
                    }
                }
            } catch {
                await MainActor.run {
                    // 실패 시 원래 상태로 복원
                    if let index = packingItems.firstIndex(where: { $0.id == item.id }) {
                        packingItems[index].isChecked = !isChecked
                    }
                    errorMessage = "상태 변경에 실패했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func deleteItem(_ item: PackingItem) {
        // Optimistic UI update
        let itemIndex = packingItems.firstIndex(where: { $0.id == item.id })
        let removedItem = itemIndex.map { packingItems.remove(at: $0) }
        
        Task {
            do {
                // 성공이면 아무것도 할 필요 없음 (이미 UI에서 제거됨)
                _ = try await packingService.deletePackingItemAsync(id: item.id)
            } catch {
                await MainActor.run {
                    // 실패 시 아이템 되돌리기
                    if let item = removedItem, let index = itemIndex {
                        packingItems.insert(item, at: min(index, packingItems.count))
                    }
                    errorMessage = "삭제에 실패했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Helpers & Computed Properties
    
    private func setupInitialExpandedCategories() {
        if let firstPersonalCategory = PackingItem.groupedByCategory(items: personalItems).keys.sorted(by: { $0.rawValue < $1.rawValue }).first {
            expandedCategories.insert(firstPersonalCategory)
        }
        
        if let firstSharedCategory = PackingItem.groupedByCategory(items: sharedItems).keys.sorted(by: { $0.rawValue < $1.rawValue }).first {
            expandedCategories.insert(firstSharedCategory)
        }
    }
    
    private func calculateHeightForCurrentDevice(screenWidth: CGFloat) -> CGFloat {
        // 기본 높이 계산
        let baseHeight = calculateContentHeight()
        
        if horizontalSizeClass == .compact && verticalSizeClass == .regular {
            // iPhone 세로 모드
            return min(baseHeight, screenWidth * 1.3)
        } else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
            // iPhone 가로 모드
            return min(baseHeight, screenWidth * 0.5)
        } else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // iPad
            return min(baseHeight, screenWidth * 0.7)
        } else {
            // 기본값
            return baseHeight
        }
    }
    
    private var dateRangeText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let start = dateFormatter.string(from: journey.startDate)
        let end = dateFormatter.string(from: journey.endDate)
        return "\(start) - \(end)"
    }
    
    private var transportIcon: String {
        switch journey.transportType {
        case .plane: return "airplane"
        case .train: return "tram.fill"
        case .ship: return "ferry.fill"
        case .bus: return "bus.fill"
        case .walk: return "figure.walk"
        case .other: return "car.fill"
        }
    }
    
    private var themeIcon: String {
        guard let firstTheme = journey.themes.first else {
            return "star.fill" // 기본 아이콘
        }
        switch firstTheme {
        case .mountain: return "mountain.2.fill"
        case .camping: return "tent.fill"
        case .waterSports: return "drop.fill"
        case .cycling: return "bicycle"
        case .shopping: return "bag.fill"
        case .themepark: return "laurel.leading"
        case .fishing: return "water.waves"
        case .skiing: return "snowflake"
        case .picnic: return "leaf.fill"
            
        case .business: return "briefcase.fill"
        case .beach: return "beach.umbrella.fill"
        case .cultural: return "building.columns.fill"
        case .photography: return "camera.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .backpacking: return "backpack.fill"
        case .wellness: return "heart.circle.fill"
        case .safari: return "binoculars.fill"
        case .cruise: return "sailboat.fill"
        case .desert: return "sun.dust.fill"
        case .sports: return "sportscourt.fill"
        case .roadtrip: return "car.fill"
        case .study: return "book.fill"
        case .glamping: return "sparkles"
        case .medical: return "cross.fill"
        case .adventure: return "figure.climbing"
        case .diving: return "figure.pool.swim"
        case .music: return "music.note"
        case .wine: return "wineglass.fill"
        case .urban: return "building.2.fill"
        case .island: return "island.fill"
        case .other: return "star.fill"
        }
    }
    
    private func categoryIcon(for category: ItemCategory) -> String {
        switch category {
        case .clothing: return "tshirt.fill"
        case .electronics: return "desktopcomputer"
        case .toiletries: return "shower.fill"
        case .documents: return "doc.fill"
        case .medicines: return "pills.fill"
        case .essentials: return "checkmark.seal.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    private var personalItems: [PackingItem] {
        packingItems.filter { !$0.isShared }
    }
    
    private var sharedItems: [PackingItem] {
        packingItems.filter { $0.isShared }
    }
    
    private var checkedItemsCount: Int {
        PackingItem.checkedItemsCount(items: packingItems)
    }
    
    private var progressValue: Float {
        packingItems.isEmpty ? 0 : Float(checkedItemsCount) / Float(packingItems.count)
    }
    
    private func calculateContentHeight() -> CGFloat {
        let extraHeight: CGFloat = 100 // 추가 패딩
        let baseHeight: CGFloat = 50 // 비어 있는 상태의 높이
        
        let items = selectedTab == 0 ? personalItems : sharedItems
        if items.isEmpty {
            return baseHeight + extraHeight
        }
        
        let groupedItems = PackingItem.groupedByCategory(items: items)
        var totalHeight: CGFloat = 0
        
        // 각 카테고리 섹션의 높이 합산
        for (category, categoryItems) in groupedItems {
            // 카테고리 헤더의 높이
            totalHeight += UIConstants.minTapTargetSize
            
            // 카테고리가 확장된 경우 항목 높이 추가
            if expandedCategories.contains(category) {
                // 항목 높이를 동적 유형에 맞게 조정
                let itemHeight: CGFloat = dynamicTypeSize >= .large ? 68 : 60
                totalHeight += CGFloat(categoryItems.count) * itemHeight
                
                // 항목 사이의 구분선에 대한 높이 추가
                if categoryItems.count > 1 {
                    totalHeight += CGFloat(categoryItems.count - 1) * 1
                }
            }
        }
        
        return totalHeight + extraHeight
    }
}


// MARK: - Supporting Views

struct FullScreenImageView: View {
    let imageUrl: String?
    @Binding var isPresented: Bool
    @State private var currentZoom: CGFloat = 1.0
    @State private var totalZoom: CGFloat = 1.0
    @State private var currentPosition: CGSize = .zero
    @State private var previousPosition: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let imageUrlString = imageUrl, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(currentZoom * totalZoom)
                            .offset(x: currentPosition.width + previousPosition.width,
                                   y: currentPosition.height + previousPosition.height)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        currentZoom = value
                                    }
                                    .onEnded { value in
                                        totalZoom = min(max(totalZoom * value, 1), 4)
                                        currentZoom = 1.0
                                        
                                        // 줌아웃시 위치 초기화
                                        if totalZoom == 1 {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                currentPosition = .zero
                                                previousPosition = .zero
                                            }
                                        }
                                    }
                                    .simultaneously(with:
                                        DragGesture()
                                            .onChanged { value in
                                                currentPosition = value.translation
                                            }
                                            .onEnded { value in
                                                previousPosition.width += value.translation.width
                                                previousPosition.height += value.translation.height
                                                currentPosition = .zero
                                            }
                                    )
                            )
                            .onTapGesture(count: 2) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    if totalZoom > 1 {
                                        totalZoom = 1
                                        currentPosition = .zero
                                        previousPosition = .zero
                                    } else {
                                        totalZoom = 2
                                    }
                                }
                            }
                    case .failure(_):
                        Image("defaultTravelImage")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    @unknown default:
                        Image("defaultTravelImage")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
            } else {
                Image("defaultTravelImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
    }
}

struct ParticipantView: View {
    let participant: User
    let isCreator: Bool
    
    init(participant: User, isCreator: Bool) {
        self.participant = participant
        self.isCreator = isCreator
    }
    
    var body: some View {
        VStack {
            ZStack {
                // 프로필 이미지 또는 폴백 UI
                if let profileImageUrl = participant.profileImage, let url = URL(string: profileImageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure(_):
                            fallbackProfileView
                        case .empty:
                            ProgressView()
                        @unknown default:
                            fallbackProfileView
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isCreator ? Color.orange : Color.white, lineWidth: 2)
                    )
                } else {
                    fallbackProfileView
                }
                
                // 방장 표시 배지
                if isCreator {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Image(systemName: "crown.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                        )
                        .offset(x: 15, y: -15)
                }
            }
            
        }
        .accessibilityLabel(isCreator ? "방장 \(participant.name)" : participant.name)
    }
    
    private var fallbackProfileView: some View {
        Circle()
            .fill(isCreator ? Color.orange : Color.main)
            .frame(width: 40, height: 40)
            .overlay(
                Text(participant.name.prefix(1).uppercased())
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 1.5)
            )
    }
}

struct PackingItemRow: View {
    let item: PackingItem
    let isSharedTab: Bool
    let onToggle: (Bool) -> Void
    let onDelete: () -> Void
    
    @State private var isChecked: Bool
    @State private var showDeleteConfirm = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    init(item: PackingItem,
         isSharedTab: Bool,
         onToggle: @escaping (Bool) -> Void,
         onDelete: @escaping () -> Void) {
        self.item = item
        self.isSharedTab = isSharedTab
        self.onToggle = onToggle
        self.onDelete = onDelete
        _isChecked = State(initialValue: item.isChecked)
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Button {
                isChecked.toggle()
                onToggle(isChecked)
            } label: {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isChecked ? .main : .gray)
                    .frame(width: UIConstants.minTapTargetSize, height: UIConstants.minTapTargetSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: dynamicTypeSize >= .large ? 18 : 16))
                    .foregroundColor(.primary)
                    .strikethrough(isChecked)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 10) {
                    Text("\(item.count)개")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    if isSharedTab, let assignedTo = item.assignedTo {
                        Text("담당: \(assignedTo.name)")
                            .font(.system(size: 12))
                            .foregroundColor(.main)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Button {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.8))
                    .frame(width: UIConstants.minTapTargetSize, height: UIConstants.minTapTargetSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                isChecked.toggle()
                onToggle(isChecked)
            }) {
                Label(
                    isChecked ? "체크 해제하기" : "체크하기",
                    systemImage: isChecked ? "circle" : "checkmark.circle"
                )
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                showDeleteConfirm = true
            }) {
                Label("삭제하기", systemImage: "trash")
            }
        }
        .alert("준비물 삭제", isPresented: $showDeleteConfirm) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("\(item.name) 준비물을 삭제하시겠습니까?")
        }
        .frame(minHeight: UIConstants.minTapTargetSize)
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
    var accessibilityMessage: String {
        return "오류: \(message)"
    }
}
