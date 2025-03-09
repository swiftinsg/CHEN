//
//  AddPersonSheet.swift
//  CHEN
//
//  Created by Sean Wong on 1/10/23.
//

import SwiftUI
import SwiftNFC
import SwiftData
struct AddStudentSheet: View {
    @Environment(\.dismiss) private var dismiss
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var writer = NFCWriter()
    @State var name: String = ""
    @State var indexNumber: String = ""
    @State var session: Session = .AM
    
    // Default to the current year
    @State var batch: Int = Calendar.current.dateComponents([.year], from: Date()).year!
    
    @State var cardID: String = ""
    
    
    var body: some View {
        Form {
            Section(header: Text("Student Information")) {
                TextField("Tan Rui Yang", text: $name)
                TextField("Student Index Number", text: $indexNumber)
                HStack {
                    Picker("Student Session", selection: $session) {
                        Text("AM").tag(Session.AM)
                        Text("PM").tag(Session.PM)
                    }.pickerStyle(.segmented)
                }
                Picker("Student Batch", selection: $batch) {
                    ForEach(2018...2050, id: \.self) {
                        Text(String($0))
                    }
                }
            }
            Button("Save Student") {
                
                let student = Student(id: UUID(), indexNumber: indexNumber, name: name, session: session, batch: Int16(batch))
                
                // Todo: make this work
                writer.startAlert = "Please scan the card to be associated with this student."
                writer.msg = student.uuid.uuidString
                writer.write()
                mc.insert(student)
                do {
//                    try moc.save()
                    try mc.save()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } catch {
                    print(error.localizedDescription)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
                dismiss()
                
                
            }
            .disabled(indexNumber == "" || name == "")
        }
        .onAppear() {
            writer.completionHandler = { error in
                if let error = error {
                    print(error.localizedDescription)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                dismiss()
            }
        }
    }
}
