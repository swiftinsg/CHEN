//
//  PersonView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import SwiftNFC

struct StudentView: View {
    @ObservedObject var student: Student
    @ObservedObject var writer = NFCWriter()
    var body: some View {
        VStack {
            Text(student.name ?? "")
            Button("Associate Card with User") {
                if let personId = student.id, let name = student.name {
                    
                    let writeText = "\(personId)"
                    writer.startAlert = "Please scan the card to be associated with this student."
                    writer.msg = writeText
                    writer.write()
                    
                    writer.endAlert = "Scanned card registered as \(name)"
                    
                }

            }
            .padding()
            .buttonStyle(.borderedProminent)
            Text("Attended Lessons")
                .font(.title)
            List(student.lessonsAttended?.allObjects as? [Attendance] ?? []) { attendanceRecord in
                Text("\(attendanceRecord.forLesson!.lessonLabel!): \(attendanceRecord.forLesson!.name!)")
            }
        }.onAppear {
            writer.completionHandler = { error in
                if let unwrappedError = error {
                    print(unwrappedError.localizedDescription)
                }
            }
        }
        
    }
    
    
}
