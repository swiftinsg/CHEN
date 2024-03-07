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
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var writer = NFCWriter()
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    var body: some View {
        VStack {
            Text(student.name ?? "")
            Button("Associate Card with User") {
                if let personId = student.id, let name = student.name {
                    
                    let writeText = "\(personId)"
                    writer.startAlert = "Please scan the card to be associated with this student."
                    writer.msg = writeText
                    writer.write()
                    writer.endAlert = "Scanned card registered as \(name)."
                    
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            Text("Attended Lessons")
                .font(.title)
            List {
                ForEach(student.lessonsAttended?.allObjects as? [Attendance] ?? [], id: \.id) { attendanceRecord in
                    HStack {
                        Text("\(attendanceRecord.forLesson!.lessonLabel!): \(attendanceRecord.forLesson!.name!)")
                        Spacer()
                        Text(dateFormatter.string(from: attendanceRecord.recordedAt!))
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                .onDelete(perform: { indexSet in
                    let attendances = student.lessonsAttended?.allObjects as? [Attendance] ?? []
                    for index in indexSet {
                        let attendance = attendances[index]
                        moc.delete(attendance)
                    }
                    do {
                        try moc.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                })
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

