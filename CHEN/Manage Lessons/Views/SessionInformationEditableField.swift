//
//  SessionInformationEditableField.swift
//  CHEN
//
//  Created by Jia Chen Yee on 20/3/24.
//

import SwiftUI
import SwiftData

struct SessionInformationEditableField: View {
    
    var title: String
    var placeholder: String
    
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    
    @Binding var value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            
            let bindingUnwrappedValue = Binding {
                value
            } set: { newValue in
                value = newValue
            }
            
            TextField(placeholder, text: bindingUnwrappedValue)
                .textSelection(.enabled)
                .onSubmit {
                    try? mc.save()
                }
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
        }
    }
}
