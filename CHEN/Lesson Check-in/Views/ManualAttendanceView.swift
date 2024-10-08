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
                    
                    let studentUUID = selectedStudent!.id!
                    
                    // Calc streak
                    // Get last available attendance for user
                    let attFetchRequest: NSFetchRequest<Attendance> = Attendance.fetchRequest()
                    attFetchRequest.predicate = NSPredicate(format: "%K == %@", "id", studentUUID as CVarArg)
                    attFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Attendance.recordedAt, ascending: false)]
                    
                    let studentAttendances = selectedStudent!.lessonsAttended!.allObjects as! [Attendance]
                    
                    // Get latest lesson
                    // NOTE: A lot of this shit implies that the student being checked is the same session as the lesson
                    // A) get it done for all day as well and B) fix all that shit and check properly later
                    if let latestAtt = studentAttendances.first, let latestLesson = latestAtt.forLesson {
                        let lessonFetchRequest: NSFetchRequest<Lesson> = Lesson.fetchRequest()
                        
                        let sessionPredicate = NSPredicate(format: "%K == %@", "session", selectedStudent!.session!)
                        let fullDayPredicate = NSPredicate(format: "%K == %@", "session", "fd")
                        let sessionOrFullDayPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [sessionPredicate, fullDayPredicate])
                        lessonFetchRequest.predicate = sessionOrFullDayPredicate
                        
                        lessonFetchRequest.sortDescriptors = [.init(keyPath: \Lesson.date, ascending: false)]
                        
                        do {
                            let lessons = try moc.fetch(lessonFetchRequest)
                            if lessons.count > 1 {
                                let lessonIndex = lessons.firstIndex(of: lesson)!
                                print("lessonIndex is \(lessonIndex)")
                                if lessonIndex != lessons.count - 1 {
                                    
                                    // lessons var contains CHRONOLOGICAL student session history (i.e, every session the student was supposed to attend)
                                    // if the LAST session the user was supposed to attend has an attendance for the student, keep up the streak
                                    // if not reset it
                                    let previousChronologicalLesson = lessons[lessonIndex + 1]
                                    if previousChronologicalLesson == latestLesson {
                                        attendance.streak = latestAtt.streak + 1
                                        print("added streak")
                                    } else {
                                        print("streak broke, set streak to 1")
                                        attendance.streak = 1
                                    }
                                } else {
                                    attendance.streak = 1
                                    print("first CHRONOLOGICAL lesson, streak = 1 no matter what")
                                }
                            } else {
                                attendance.streak = 1
                                print("no lesson found set streak to 1")
                            }
                        } catch {
                            print(error.localizedDescription)
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    } else {
                        attendance.streak = 1
                    }
                    
                    do {
                        try moc.save()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } catch {
                        print(error.localizedDescription)
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                    dismiss()
                }), secondaryButton: .cancel())
            }
            .navigationTitle("Select Student")
        }
        
    }
}
