//
//  AddPackingItemSheetView.swift
//  Packing
//
//  Created by 이융의 on 4/13/25.
//

import SwiftUI

struct AddPackingItemSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var itemName: String = ""
    @State private var itemCount: Int = 1
    @State private var selectedCategory: ItemCategory = .essentials
    @State private var isShared: Bool = false
    @State private var selectedAssignee: String?
    
    // API 호출 관련 상태
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    let journey: Journey
    let onSave: (PackingItem) -> Void
    
    // 서비스
    private let packingService = PackingItemService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    // 아이템 이름 입력
                    Section(header: Text("아이템 정보".localized)) {
                        TextField("준비물 이름".localized, text: $itemName)
                        
                        Stepper("수량: %d개".localized(with: itemCount), value: $itemCount, in: 1...99)
                    }
                    
                    // 카테고리 선택
                    Section(header: Text("카테고리".localized)) {
                        Picker("카테고리".localized, selection: $selectedCategory) {
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                HStack {
                                    Image(systemName: categoryIcon(for: category))
                                    Text("  \(category.displayName)")
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    // 개인/공용 선택
                    Section(header: Text("준비물 유형".localized)) {
                        Toggle("공용 준비물".localized, isOn: $isShared)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    
                    // 담당자 지정 (공용일 때만 표시)
                    if isShared {
                        Section(header: Text("담당자".localized)) {
                            Picker("담당자".localized, selection: $selectedAssignee) {
                                Text("담당자 미지정".localized).tag(String?.none)
                                ForEach(self.journey.participants.map { $0.id }, id: \.self) { participantId in
                                    let isCreator = participantId == journey.creatorId
                                    Text(isCreator ? "방장".localized : "참가자".localized)
                                        .tag(participantId as String?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .transition(.opacity)
                        .animation(.default, value: isShared)
                    }
                }
                
                // 로딩 오버레이
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("저장 중...".localized)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .frame(width: 150, height: 150)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .navigationTitle("준비물 추가".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소".localized) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장".localized) {
                        saveItem()
                    }
                    .disabled(itemName.isEmpty || isLoading)
                }
            }
            .alert(item: Binding(
                get: { errorMessage.map { ErrorWrapper(message: $0) } },
                set: { errorMessage = $0?.message }
            )) { error in
                Alert(
                    title: Text("오류".localized),
                    message: Text(error.message),
                    dismissButton: .default(Text("확인".localized))
                )
            }
        }
    }
    
    private func saveItem() {
        guard !itemName.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                let newItem = try await packingService.createPackingItemAsync(
                    journeyId: journey.id,
                    name: itemName,
                    count: itemCount,
                    category: selectedCategory,
                    isShared: isShared,
                    assignedTo: isShared ? selectedAssignee : nil
                )
                
                await MainActor.run {
                    isLoading = false
                    onSave(newItem)
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "준비물 추가에 실패했습니다: \(error.localizedDescription)"
                }
            }
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
}

// MARK: - Sheet Presentation Extension
extension View {
    func addPackingItemSheet(journey: Journey, isPresented: Binding<Bool>, onSave: @escaping (PackingItem) -> Void) -> some View {
        self.sheet(isPresented: isPresented) {
            AddPackingItemSheet(journey: journey, onSave: onSave)
                .presentationDetents([.medium, .large])
        }
    }
}
