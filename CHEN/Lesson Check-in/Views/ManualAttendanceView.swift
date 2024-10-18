//
//  ManualAttendanceView.swift
//  CHEN
//
//  Created by Sean Wong on 3/2/24.
//

import SwiftUI
import CoreData

struct ManualAttendanceView: View {
    var lesson: Lesson
    @FetchRequest(sortDescriptors: [.init(keyPath: \Student.name, ascending: true)]) var students: FetchedResults<Student>
    @State var showAddSheet: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    
    var searchedStudents: [Student] {
        var studentsArray: [Student] = []
        
        // Filter students based on session
        switch lesson.session! {
        case "AM":
            studentsArray = students.filter {
                $0.session ?? "Unknown Sesison" == "AM"
            }
        case "PM":
            studentsArray = students.filter {
                $0.session ?? "Unknown Session" == "PM"
            }
        default:
            // This is the "full day" case or something has gone horribly wrong case
            studentsArray = students.compactMap({ student in
                student
            })
        }
        
        studentsArray = studentsArray.sorted {
            ($0.indexNumber ?? "") < ($1.indexNumber ?? "")
        }
        
        
        switch search {
        case "":
            return studentsArray
        default:
            return studentsArray.filter { student in
                student.name!.localizedCaseInsensitiveContains(search) || student.indexNumber!.localizedCaseInsensitiveContains(search)
            }
        }
    }
    
    @State var search: String = ""
    @State var showMarkAlert = false
    @State var selectedStudent: Student?
    
    var body: some View {
        ZStack {
            VStack {
                // Implement searches properly (see LessonView)
                List(searchedStudents) { student in
                    Button {
                        selectedStudent = student
                        showMarkAlert = true
                    } label: {
                        HStack {
                            Text(student.indexNumber ?? "")
                                .monospaced()
                            Text(student.name!)
                            Spacer()
                        }
                    }
                }
                .searchable(text: $search)
            }
            .alert(isPresented: $showMarkAlert) {
                Alert(title: Text("Attendance"),
                      message: Text("Mark \(selectedStudent?.name ?? "student") as attending?"),
                      primaryButton: .default(Text("Yes"), action: {
                    
                    guard let unwrappedSelectedStudent = selectedStudent else { return }
                    guard let studentAttendedLessonsSet = unwrappedSelectedStudent.attendances else { return }
                    var studentAttendedLessons: [Lesson] = studentAttendedLessonsSet.allObjects.compactMap {
                        let att = $0 as! Attendance
                        return att.forLesson!
                    }
                
                    // Add attendance record
                    let attendance = Attendance(context: moc)
                    attendance.attendanceType = 1
                    attendance.forLesson = lesson
                    attendance.person = selectedStudent!
                    attendance.recordedAt = Date()
                    
                    // Check if there are attended lessons AFTER this lesson
                    // If so they need to be recalculated
                    // Streak history before this is not affected
                    studentAttendedLessons = studentAttendedLessons.filter {
                        $0.date! > lesson.date!
                    }
                    if studentAttendedLessons.count > 0 {
                        // Recalculate ALL streaks (may bridge two streaks together)
                        do {
                            guard let studentAttendances = unwrappedSelectedStudent.attendances else { throw "Student attendances do not exist" }
                            let attendances = studentAttendances.allObjects.map {
                                $0 as! Attendance
                            }
                            try recalculateStreaks(for: attendances, withContext: moc)
                            try moc.save()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } catch {
                            print(error.localizedDescription)
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    } else {
                        // This incoming streak is the latest, calculate it as per normal
                        do {
                            try calculateStreak(for: attendance, withContext: moc)
                            try moc.save()
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } catch {
                            print(error.localizedDescription)
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    }
                    dismiss()
                }), secondaryButton: .cancel())
            }
            .navigationTitle("Select Student")
        }
        
    }
}
