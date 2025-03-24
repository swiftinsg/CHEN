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
    @Environment(\.modelContext) private var mc
    @ObservedObject var writer = NFCWriter()
    @State var name: String = ""
    @State var indexNumber: String = ""
    @State var session: Session = .AM
    @State var studentType: StudentType = .student
    // Default to the current year
    @State var batch: Int = Calendar.current.dateComponents([.year], from: Date()).year!
    
    @State var cardID: String = ""
    
    
    var body: some View {
        Form {
            Section(header: Text("Student Information")) {
                TextField("Tan Rui Yang", text: $name)
                TextField("Student Index Number", text: $indexNumber)
                Picker("Student Batch", selection: $batch) {
                    ForEach(2018...2050, id: \.self) {
                        Text(String($0))
                    }
                }
            
            }
            
            Section(header: Text("Student Type")) {
                HStack {
                    Picker("Student Type", selection: $studentType) {
                        Text("Student").tag(StudentType.student)
                        Text("Alumni").tag(StudentType.alumni)
                    }.pickerStyle(.segmented)
                }
            }
            
            if studentType == .student {
                Section(header: Text("Student Session")) {
                    HStack {
                        Picker("Student Session", selection: $session) {
                            Text("AM").tag(Session.AM)
                            Text("PM").tag(Session.PM)
                        }.pickerStyle(.segmented)
                    }
                }
            }
            Button("Save Student") {
                if studentType == .alumni {
                    session = .fullDay
                }
                let student = Student(uuid: UUID(), indexNumber: indexNumber, name: name, session: session, batch: Int16(batch), studentType: studentType)
                
                if studentType == .student {
                    writer.startAlert = "Please scan the card to be associated with this student."
                    writer.msg = student.uuid.uuidString
                    writer.write()
                }
                mc.insert(student)
                do {
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
        .onChange(of: studentType, { _, newValue in
            // reset session
            if newValue == .student {
                session = .AM
            }
        })
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
