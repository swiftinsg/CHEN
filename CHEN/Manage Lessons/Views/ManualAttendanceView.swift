//
//  ManualAttendanceView.swift
//  CHEN
//
//  Created by Sean Wong on 3/2/24.
//

import SwiftUI
import AlertToast
import CoreData

struct ManualAttendanceView: View {
    var lesson: Lesson
    @FetchRequest(sortDescriptors: [.init(keyPath: \Student.name, ascending: true)]) var students: FetchedResults<Student>
    @State var showAddSheet: Bool = false
    var deletedStudent: Int = 0
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    
    //    @Binding var alertToast: AlertToast
    //    @Binding var showAlertToast: Bool
    var searchedStudents: [Student] {
        let studentsArray = students.compactMap { student in
            student
        }.sorted {
            ($0.indexNumber ?? "") < ($1.indexNumber ?? "")
        }
        
        switch search {
        case "":
            return studentsArray
        default:
            return studentsArray.filter { student in
                student.name!.localizedCaseInsensitiveContains(search)
            }
        }
    }
    
    @State var search: String = ""
    @State var showAlert = false
    @State var selectedStudent: Student?
    
    var body: some View {
        ZStack {
            VStack {
                // Implement searches properly (see LessonView)
                List(searchedStudents) { student in
                    Button {
                        selectedStudent = student
                        showAlert = true
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Attendance"),
                      message: Text("Mark \(selectedStudent?.name ?? "student") as attending?"),
                      primaryButton: .default(Text("Yes"), action: {
                    let attendance = Attendance(context: moc)
                    attendance.attendanceType = 1
                    attendance.forLesson = lesson
                    attendance.person = selectedStudent!
                    attendance.recordedAt = Date()
                    
                    
                    do {
                        let lessonFetchRequest: NSFetchRequest<Lesson> = Lesson.fetchRequest()
                        
                        lessonFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Lesson.date, ascending: false)]
                        
                        let lessons = try moc.fetch(lessonFetchRequest)
                        var streak = 0
                        print("Lessons is \(lessons)")
                        
                        // Get all lessons (newest to first), filter for IF student session equals session
                        // OR if the lesson is a full day session
                        
                        let filteredLessons = lessons.filter({ selectedStudent!.session ?? "nothing" == $0.session ?? "nothing" || $0.session ?? "nothing" == "fd"})
                        print("FilteredLessons is \(filteredLessons)")
                        // Go through each lesson, find if student attended, if they did +1 streak
                        for lesson in filteredLessons {
                            if let att = lesson.attendances {
                                let attendances = att.array as! [Attendance]
                                print("att is \(attendances)")
                                guard attendances.count != 0 else { break }
                                let search = attendances.filter({ $0.person!.id == selectedStudent!.id })
                                print("search is \(search)")
                                if search.count > 0 {
                                    // Student attended lesson
                                    // Add one to streak
                                    streak += 1
                                } else {
                                    // Streak ends here break out of loop
                                    streak += 1
                                    break
                                }
                            }
                        }
                        
                        selectedStudent!.streak = Int16(streak)
                        try moc.save()
                        //                        showAlertToast = true
                        //                        alertToast = AlertToast(displayMode: .banner(.slide), type: .complete(.green), title: "Success", subTitle: "Attendance marked", style: .style( subTitleFont: .callout))
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } catch {
                        print(error.localizedDescription)
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        //                        showAlertToast = true
                        //                        alertToast = AlertToast(displayMode: .banner(.slide), type: .error(.red), title: "An error occured", subTitle: error.localizedDescription)
                        
                    }
                    
                    dismiss()
                }), secondaryButton: .cancel())
            }
            .navigationTitle("Select Student")
        }
        
    }
}
