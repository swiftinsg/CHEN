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
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    return "This is not a CHEN registered card."
                }
                
                let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
                
                fetchRequest.predicate = NSPredicate(
                    format: "%K == %@", "id", studentUUID as CVarArg
                )
                do {
                    var students = try moc.fetch(fetchRequest)

                    guard let foundStudent = students.first else {
                        return "Student not found"
                    }
                    
                    if let name = foundStudent.name {
                        studentName = name
                        
                        
                        // create attendance object
                        let attendance = Attendance(context: moc)
                        attendance.attendanceType = 1
                        attendance.forLesson = lesson
                        attendance.recordedAt = Date.now
                        attendance.person = foundStudent
                        
                        guard let studentAttendedLessonsSet = foundStudent.attendances else { return "Student attendances do not exist" }
                        var studentAttendedLessons: [Lesson] = studentAttendedLessonsSet.allObjects.compactMap {
                            let att = $0 as! Attendance
                            return att.forLesson!
                        }
                        // Calc streak
                        // Check if there are attended lessons AFTER this lesson
                        // If so they need to be recalculated
                        // Streak history before this is not affected
                        studentAttendedLessons = studentAttendedLessons.filter {
                            $0.date! > lesson.date!
                        }
                        if studentAttendedLessons.count > 0 {
                            // Recalculate ALL streaks (may bridge two streaks together)
                            
                            guard let studentAttendances = foundStudent.attendances else { throw "Student attendances do not exist" }
                            let attendances = studentAttendances.allObjects.map {
                                $0 as! Attendance
                            }
                            try recalculateStreaks(for: attendances, withContext: moc)
                            try moc.save()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } else {
                            // This incoming streak is the latest, calculate it as per normal
                            
                            try calculateStreak(for: attendance, withContext: moc)
                            try moc.save()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                        }
                        
                        try moc.save()
                        return "Welcome, \(name)!"
                    } else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        return "Student name not identified"
                    }
                } catch {
                    print(error.localizedDescription)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    return "There was an error scanning the student: \(error.localizedDescription)"
                }
                
            }
        }
        .navigationTitle(lesson.session ?? "")
    }
}



