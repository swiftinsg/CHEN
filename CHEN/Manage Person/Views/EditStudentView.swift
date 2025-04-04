//
//  EditStudentSheet.swift
//  CHEN
//
//  Created by Sean Wong on 10/11/23.
//

import SwiftUI
import SwiftNFC
import SwiftData
struct EditStudentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var mc
    
    @ObservedObject var writer = NFCWriter()
    @Bindable var student: Student
    
    @State var showCardAlert: Bool = false
    @State var name: String = ""
    @State var indexNumber: String = ""
    
    // Default to the current year
    @State var batch: Int = Calendar.current.dateComponents([.year], from: Date()).year!
    
    @State var cardID: String = ""

    var body: some View {
        Form {
            Section(header: Text("Student Information")) {
                
                TextField("Student Name", text: $student.name)
                TextField("Student Index Number", text: $student.indexNumber)
                Picker("Student Batch", selection: $student.batch) {
                    ForEach(2018...2050, id: \.self) {
                        Text(String($0))
                            .tag(Int16($0))
                    }
                }
                
            }
            Button("Save Student") {
                // Maybe have an alert asking the person whether they want to re-assign a card
                
                do {
                    showCardAlert = true
                    try mc.save()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } catch {
                    print(error.localizedDescription)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            
            }
            .disabled(student.indexNumber == "" || student.name == "")
        }
        .onAppear() {
            writer.completionHandler = { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    dismiss()
                }
            }
        }
        .alert("Do you want to re-associate \(student.name) with another card?", isPresented: $showCardAlert) {
            Button("Yes") {
                // write UUID to card
                writer.startAlert = "Please scan the card to be associated with this student."
                writer.msg = "\(student.id)"
                writer.write()
            }
            Button("No", role: .cancel) {
                dismiss()
            }
        }
    }
}
