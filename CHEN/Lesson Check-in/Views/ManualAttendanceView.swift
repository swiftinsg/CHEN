//
//  ManualAttendanceView.swift
//  CHEN
//
//  Created by Sean Wong on 3/2/24.
//

import SwiftUI
import AlertToast

struct ManualAttendanceView: View {
    var lesson: Lesson
    @FetchRequest(sortDescriptors: [.init(keyPath: \Student.name, ascending: true)]) var students: FetchedResults<Student>
    @State var showAddSheet: Bool = false
    var deletedStudent: Int = 0
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    
    @Binding var alertToast: AlertToast
    @Binding var showAlertToast: Bool
    var searchedStudents: [Student] {
        let studentsArray = students.compactMap { student in
            student
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
        NavigationStack {
            ZStack {
                VStack {
                    // Implement searches properly (see LessonView)
                    List(searchedStudents) { student in
                        Button {
                            selectedStudent = student
                            showAlert = true
                        } label: {
                            Text(student.name ?? "Unknown Data")
                        }
                    }
                    .searchable(text: $search)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Attendance"), message: Text("Mark student as attending?"), primaryButton: .default(Text("Yes"), action: {
                            let attendance = Attendance(context: moc)
                        attendance.attendanceType = 1
                        attendance.forLesson = lesson
                        attendance.person = selectedStudent!
                        attendance.recordedAt = Date()
                        
                        do {
                            try moc.save()
                            showAlertToast = true
                            alertToast = AlertToast(displayMode: .banner(.slide), type: .complete(.green), title: "Success", subTitle: "Attendance marked", style: .style( subTitleFont: .callout))
                        } catch {
                            print(error.localizedDescription)
                            showAlertToast = true
                            alertToast = AlertToast(displayMode: .banner(.slide), type: .error(.red), title: "An error occured", subTitle: error.localizedDescription)
                            
                        }
                        
                        dismiss()
                        }), secondaryButton: .cancel())
                }
            }.navigationTitle(Text("Select Student"))
        }
        
    }
}
