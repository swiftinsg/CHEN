//
//  ScanView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import SwiftNFC
import CoreData
import SwiftUINFC
import CoreNFC

struct ScanView: View {
    @ObservedObject var reader = NFCReader()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    
    @State var studentName: String = "Scan in a student!"
    @State var lesson: Lesson
    
    @State private var isReaderPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        isReaderPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "scanner")
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text("Scan Badge")
                                    .font(.headline)
                                Text("Tap to scan on a student's badge.")
                            }
                            .foregroundStyle(Color.primary)
                            Spacer()
                        }
                    }
                    NavigationLink {
                        ManualAttendanceView(lesson: lesson)
                    } label: {
                        Text("Manually mark a student as present")
                    }
                }
                
                let attendances = lesson.attendances?.array as? [Attendance]
                
                Section("Marked attendance") {
                    ForEach(attendances ?? []) { attendance in
                        Text(attendance.person?.name ?? "")
                    }
                }
            }
            .nfcReader(isPresented: $isReaderPresented) { messages in
                guard let message = messages.first,
                      let record = message.records.first,
                      let studentUUID = UUID(uuidString: String(decoding: record.payload, as: UTF8.self)) else {
                    return "This is not a CHEN registered card."
                }
                
                let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
                
                fetchRequest.predicate = NSPredicate(
                    format: "%K == %@", "id", studentUUID as CVarArg
                )
                
                let lessonFetchRequest: NSFetchRequest<Lesson> = Lesson.fetchRequest()
                
                lessonFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Lesson.date, ascending: false)]
                do {
                    let students = try moc.fetch(fetchRequest)
                    guard let foundStudent = students.first else {
                        return "Student not found"
                    }
                    let lessons = try moc.fetch(lessonFetchRequest)
                    
                    var streak = 0
                    
                    // Get all lessons (newest to first), filter for IF student session equals session
                    // OR if the lesson is a full day session
                    let filteredLessons = lessons.filter({ foundStudent.session ?? "nothing" == $0.session ?? "nothing" || $0.session ?? "nothing" == "fd"})
                    
                    // Go through each lesson, find if student attended, if they did +1 streak
                    for lesson in filteredLessons {
                        if let att = lesson.attendances {
                            let attendances = att.array as! [Attendance]
                            let search = attendances.filter({ $0.person!.id == foundStudent.id })
                            if search.count > 0 {
                                // Student attended lesson
                                // Add one to streak
                                streak += 1
                            } else {
                                // Streak ends here break out of loop
                                break
                            }
                        }
                    }
                    
                    if let name = foundStudent.name {
                        studentName = name
                        
                        // create attendance object
                        let attendance = Attendance(context: moc)
                        attendance.attendanceType = 1
                        attendance.forLesson = lesson
                        attendance.recordedAt = Date.now
                        
                        attendance.person = foundStudent
                        
                        // update streak
                        foundStudent.streak = Int16(streak)
                        
                        try moc.save()
                        
                        return name
                    } else {
                        return "Student name not identified"
                    }
                } catch {
                    print(error.localizedDescription)
                    return "There was an error scanning the student: \(error.localizedDescription)"
                }
            }
        }
        .navigationTitle(lesson.session ?? "")
    }
}



