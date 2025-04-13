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
    
    let journey: Journey
    let onSave: (PackingItem) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                // 아이템 이름 입력
                Section(header: Text("아이템 정보")) {
                    TextField("준비물 이름", text: $itemName)
                    
                    Stepper("수량: \(itemCount)개", value: $itemCount, in: 1...99)
                }
                
                // 카테고리 선택
                Section(header: Text("카테고리")) {
                    Picker("카테고리", selection: $selectedCategory) {
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
                Section(header: Text("준비물 유형")) {
                    Toggle("공용 준비물", isOn: $isShared)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                // 담당자 지정 (공용일 때만 표시)
                if isShared {
                    Section(header: Text("담당자")) {
                        Picker("담당자", selection: $selectedAssignee) {
                            Text("담당자 미지정").tag(String?.none)
                            ForEach(journey.participants, id: \.self) { participantId in
                                let isCreator = participantId == journey.creatorId
                                Text(isCreator ? "방장" : "참가자")
                                    .tag(participantId as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .transition(.opacity)
                    .animation(.default, value: isShared)
                }
            }
            .navigationTitle("준비물 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveItem()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        let newItem = PackingItem(
            journeyId: journey.id,
            name: itemName,
            count: itemCount,
            category: selectedCategory,
            isShared: isShared,
            assignedTo: isShared ? selectedAssignee : nil,
            createdBy: User.currentUser.id
        )
        
        onSave(newItem)
        presentationMode.wrappedValue.dismiss()
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

//// MARK: - Preview
//struct AddPackingItemSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPackingItemSheet(
//            journey: JourneyPreviewProvider.sampleJourney,
//            onSave: { _ in }
//        )
//    }
//}

