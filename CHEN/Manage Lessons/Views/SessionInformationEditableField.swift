//
//  SessionInformationEditableField.swift
//  CHEN
//
//  Created by Jia Chen Yee on 20/3/24.
//

import SwiftUI

struct SessionInformationEditableField: View {
    
    var title: String
    var placeholder: String
    
    @Environment(\.managedObjectContext) private var moc
    
    @Binding var value: String?
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            
            let bindingUnwrappedValue = Binding {
                value ?? ""
            } set: { newValue in
                value = newValue
            }
            
            TextField(placeholder, text: bindingUnwrappedValue)
                .textSelection(.enabled)
                .onSubmit {
                    try? moc.save()
                }
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
        }
    }
}
