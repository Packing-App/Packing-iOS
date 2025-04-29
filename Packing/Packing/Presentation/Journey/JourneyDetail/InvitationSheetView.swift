//
//  InvitationSheetView.swift
//  Packing
//
//  Created by 이융의 on 4/29/25.
//

import SwiftUI

struct InvitationSheetView: View {
    var body: some View {
        List {
            Text("InvitationSheetView")
        }
        .searchable(text: .constant("이메일을 입력해주세요"), placement: .automatic, prompt: Text("여행을 같이 갈 친구를 초대해보세요."))
    }
}

#Preview {
    InvitationSheetView()
}
