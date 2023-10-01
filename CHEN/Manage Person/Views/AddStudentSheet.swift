//
//  AddPersonSheet.swift
//  CHEN
//
//  Created by Sean Wong on 1/10/23.
//

import SwiftUI
import SwiftNFC

struct AddStudentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var writer = NFCWriter()
    @State var name: String = ""
    
    // Default to the current year
    @State var batch: Int = Calendar.current.dateComponents([.year], from: Date()).year!
    
    @State var cardID: String = ""
    var body: some View {
        Form {
            Section(header: Text("Student Information")) {
                TextField("Tan Rui Yang", text: $name)
                Picker("Student Batch", selection: $batch) {
                    ForEach(2018...2050, id: \.self) {
                        Text(String($0))
                    }
                }
                
            }
            Button("Save Student") {
                let student = Student(context:moc)
        
                student.id = UUID()
                student.name = name
                student.batch = Int16(batch)
                
                // Todo: make this work
                writer.msg = student.name!
                writer.write()
                do {
                    try moc.save()
                } catch {
                    print("An error occured whilst saving the new student.")
                }
                dismiss()
                
            }
        }
    }
}
