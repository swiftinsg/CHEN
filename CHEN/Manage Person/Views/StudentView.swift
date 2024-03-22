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
        Form {
            Section("Name") {
                Text(student.name ?? "")
            }
            
            Section("Student Details") {
                HStack {
                    Text("UUID")
                    Spacer()
                    Text(student.id?.uuidString ?? "")
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                        .monospaced()
                }
                
                HStack {
                    Text("Index Number")
                    Spacer()
                    Text(student.indexNumber ?? "")
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                        .monospaced()
                }
                
                HStack {
                    Text("Batch Year")
                    Spacer()
                    Text(String(student.batch))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                        .monospaced()
                }
                
                HStack {
                    Text("Session")
                    Spacer()
                    Text(student.session ?? "No Value")
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                }
            }
 
            Button {
                if let personId = student.id, let name = student.name {
                    
                    let writeText = "\(personId)"
                    writer.startAlert = "Please scan the card to be associated with this student."
                    writer.msg = writeText
                    writer.write()
                    writer.endAlert = "Scanned card registered as \(name)."
                }
            } label: {
                Label("Pair card", systemImage: "lanyardcard")
            }
            
            Section("Attended Lessons") {
                let attendedLessons = (student.lessonsAttended?.allObjects as? [Attendance] ?? []).sorted(by: {
                    ($0.recordedAt ?? .distantPast) < ($1.recordedAt ?? .distantPast)
                })
                
                ForEach(attendedLessons, id: \.id) { attendanceRecord in
                    LessonRowView(lesson: attendanceRecord.forLesson!, date: attendanceRecord.recordedAt!)
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        let attendance = attendedLessons[index]
                        moc.delete(attendance)
                    }
                    do {
                        try moc.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                })
            }
            

        }
        .onAppear {
            writer.completionHandler = { error in
                if let unwrappedError = error {
                    print(unwrappedError.localizedDescription)
                }
            }
        }
        .navigationTitle(student.name ?? "")
    }
    
    
}

