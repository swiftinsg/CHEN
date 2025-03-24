//
//  PersonView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import SwiftNFC
import SwiftData

struct StudentView: View {
    @Bindable var student: Student
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    @ObservedObject var writer = NFCWriter()
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    var body: some View {
        Form {
            Section("Name") {
                Text(student.name)
                
            }
            
            Section("Student Details") {
                HStack {
                    Text("UUID")
                    Spacer()
                    Text(student.uuid.uuidString)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .multilineTextAlignment(.trailing)
                        .monospaced()
                }
                
                HStack {
                    SessionInformationEditableField(title: "Index Number", placeholder: "Index Number", value: $student.indexNumber)
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
                
                if student.studentType == .student {
                    HStack {
                        Text("Session")
                        Spacer()
                        Text(student.session.rawValue)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Streak")
                        Spacer()
                        Text(getStreak(student))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                
                
            }
            if student.studentType == .student {
                Button {
                    let personId = student.uuid.uuidString
                    let name = student.name
                    
                    let writeText = personId
                    writer.startAlert = "Please scan the card to be associated with this student."
                    writer.msg = writeText
                    writer.write()
                    writer.endAlert = "Scanned card registered as \(name)."
                    
                } label: {
                    Label("Pair card", systemImage: "lanyardcard")
                }
            }
            Section("Attended Lessons") {
                let attendedLessons = student.attendances.sorted(by: {
                    ($0.forLesson!.date) > ($1.forLesson!.date)
                })
                if attendedLessons.count > 0 {
                    ForEach(attendedLessons, id: \.id) { attendanceRecord in
                        LessonRowView(lesson: attendanceRecord.forLesson!, date: attendanceRecord.recordedAt)
                    }
                    .onDelete(perform: { indexSet in
                        var studentAttendances = student.attendances
                        for index in indexSet {
                            let attendance = attendedLessons[index]
                            mc.delete(attendance)
                            do {
                                try mc.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                            studentAttendances.removeAll { att in
                                att == attendance
                            }
                        }
                        do {
                            try recalculateStreaks(for: studentAttendances, withContainer: mc.container)
                            try mc.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                    })
                } else {
                    ContentUnavailableView("No Attendances", systemImage: "person.crop.circle.badge.questionmark.fill")
                }
            }
            
            
        }
        .onAppear {
            writer.completionHandler = { error in
                if let unwrappedError = error {
                    print(unwrappedError.localizedDescription)
                }
            }
        }
        .navigationTitle(student.name)
    }
    
    func getStreak(_ student: Student) -> String {
        var attendanceSet = student.attendances
        
        // sort attendances by lesson date as they're not ordered
        attendanceSet.sort { att1, att2 in
            att1.forLesson!.date > att2.forLesson!.date
        }
        if attendanceSet.count > 0 {
            return String(attendanceSet.first!.streak)
        } else {
            return "0"
        }
        
        
    }
    
    
}

