//
//  JourneyDetailViewController.swift
//  Packing
//
//  Created by 이융의 on 4/12/25.
//
import UIKit
import SwiftUI

class JourneyDetailViewController: UIViewController {
    
    // MARK: - Properties
    var journey: Journey?
    private var hostingController: UIHostingController<JourneyDetailView>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .main
        
        appearance.shadowColor = .clear
        
        // Apply the appearance to all navigation bar states
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - Setup
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
        
        // Setup constraints
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}

import SwiftUI
import RxSwift

// MARK: - SwiftUI JourneyDetailView

struct JourneyDetailView: View {
    // MARK: - Properties
    let journey: Journey
    @State private var packingItems: [PackingItem] = []
    @State private var selectedTab = 0
    @State private var expandedCategories: Set<ItemCategory> = Set()
    @State private var showingAddItemSheet = false
    
    // State for API calls
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Service
    private let packingService = PackingItemService()
    
    // MARK: - Body
    var body: some View {
        Group {
            if isLoading && packingItems.isEmpty {
                loadingView
            } else {
                mainContentView
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
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("준비물 로딩 중...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Image
                headerSection
                    .safeAreaPadding(.top)
                
                // Content
                VStack(spacing: 20) {
                    // Journey Info
                    journeyInfoSection
                    
                    Divider()
                    
                    // Participants
                    participantsSection
                    
                    Divider()
                    
                    // Weather Section
                    WeatherSection(journey: journey)
                    
                    Divider()
                    
                    // Progress
                    progressSection
                    
                    // Item Tabs (Personal & Shared)
                    itemsTabView
                }
                .padding(.top, 20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(y: -20)
            }
        }
        .refreshable {
            await refreshPackingItems()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack(alignment: .top) {
            if let imageUrlString = journey.imageUrl, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Image("journey_default")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        Image("journey_default")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(height: 250)
                .clipped()
            } else {
                Image("journey_default")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
            }
        }
        .frame(height: 200)
    }
    
    // MARK: - Journey Info Section
    private var journeyInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(journey.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
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
                Text("테마: \(journey.theme.displayName)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Participants Section
    private var participantsSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("여행 참가자")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                Spacer()
                Button(action: {
                    // 초대 기능 구현
                }, label: {
                    Text("초대하기")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                })
                .padding(.trailing)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    // ZStack으로 감싸서 모든 참가자 프로필을 겹치게 표시
                    ZStack(alignment: .leading) {
                        // 먼저 일반 참가자들을 뒤에서부터 렌더링
                        let regularParticipants = journey.participants.filter { $0.id != journey.creatorId }.map { $0.id }
                        ForEach(Array(regularParticipants.enumerated().reversed()), id: \.element) { index, participantId in
                            ParticipantView(name: "참가자 \(index + 2)", isCreator: false)
                                .offset(x: CGFloat(index + 1) * 15.0) // 방장 뒤에 배치
                        }
                        
                        // 방장을 맨 앞(맨 왼쪽)에 배치
                        if journey.participants.map { $0.id }.contains(journey.creatorId) {
                            ParticipantView(name: "방장", isCreator: true)
                                .offset(x: 0) // 맨 앞에 배치
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, CGFloat(journey.participants.count - 1) * 15 + 20) // 겹침에 따른 여백 조정
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
                .progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
                .frame(height: 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    // MARK: - Items Tab View
    private var itemsTabView: some View {
        VStack(spacing: 10) {
            Picker("준비물 유형", selection: $selectedTab) {
                Text("개인 준비물").tag(0)
                Text("공용 준비물").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            
            TabView(selection: $selectedTab) {
                // Personal Items Tab
                packingItemsList(items: personalItems)
                    .tag(0)
                
                // Shared Items Tab
                packingItemsList(items: sharedItems)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: calculateContentHeight())
            
            // Add Item Button
            Button {
                showingAddItemSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("준비물 추가하기")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(.horizontal, 20)
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
        .padding(.horizontal, 20)
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
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        Text(category.displayName)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                        
                        Text("\(items.count)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 12)
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
//                if !success {
//                    // 실패 시 아이템 되돌리기
//                    await MainActor.run {
//                        if let item = removedItem, let index = itemIndex {
//                            packingItems.insert(item, at: min(index, packingItems.count))
//                        }
//                        errorMessage = "삭제에 실패했습니다."
//                    }
//                }
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
        switch journey.theme {
        case .mountain: return "mountain.2.fill"
        case .camping: return "tent.fill"
        case .waterSports: return "drop.fill"
        case .cycling: return "bicycle"
        case .shopping: return "bag.fill"
        case .themepark: return "laurel.leading"
        case .fishing: return "water.waves"
        case .skiing: return "snowflake"
        case .picnic: return "leaf.fill"
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
        let extraHeight: CGFloat = 100 // Extra padding
        let baseHeight: CGFloat = 50 // Height for empty state
        
        let items = selectedTab == 0 ? personalItems : sharedItems
        if items.isEmpty {
            return baseHeight + extraHeight
        }
        
        let groupedItems = PackingItem.groupedByCategory(items: items)
        var totalHeight: CGFloat = 0
        
        // Add up heights for each category section
        for (category, categoryItems) in groupedItems {
            // Height for category header
            totalHeight += 44
            
            // Add height for items if category is expanded
            if expandedCategories.contains(category) {
                totalHeight += CGFloat(categoryItems.count) * 60
                
                // Add height for dividers between items
                if categoryItems.count > 1 {
                    totalHeight += CGFloat(categoryItems.count - 1) * 1
                }
            }
        }
        
        return totalHeight + extraHeight
    }
}

// MARK: - Supporting Views
struct ParticipantView: View {
    let name: String
    let isCreator: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 프로필 이미지
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                )
            
            // 방장 표시 (왕관 아이콘)
            if isCreator {
                Image(systemName: "crown.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
                    .offset(x: -12, y: -2)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
        }
    }
}

struct PackingItemRow: View {
    let item: PackingItem
    let isSharedTab: Bool
    let onToggle: (Bool) -> Void
    let onDelete: () -> Void
    
    @State private var isChecked: Bool
    @State private var showDeleteConfirm = false
    
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
                    .foregroundColor(isChecked ? .blue : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .strikethrough(isChecked)
                
                HStack(spacing: 10) {
                    Text("\(item.count)개")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    if isSharedTab, let assignedTo = item.assignedTo {
                        Text("담당: 참가자")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Delete button
            Button {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.8))
            }
            .padding(.trailing, 5)
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
    }
}

#Preview {
    JourneyDetailView(journey: Journey.examples.first!)
}


// Error Wrapper for alerts
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let message: String
}
