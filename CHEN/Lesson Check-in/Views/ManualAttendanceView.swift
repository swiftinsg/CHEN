//
//  ManualAttendanceView.swift
//  CHEN
//
//  Created by Sean Wong on 3/2/24.
//

import SwiftUI
import CoreData
import SwiftData

struct ManualAttendanceView: View {
    var lesson: Lesson
    @Query(sort: \Student.name) var students: [Student]
    @State var showAddSheet: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    
    var searchedStudents: [Student] {
        var studentsArray: [Student] = []
        
        // Filter students based on session
        
        switch lesson.session {
            //
        case .AM:
            studentsArray = students.filter {
                $0.session == .AM || $0.studentType == .alumni
            }
        case .PM:
            studentsArray = students.filter {
                $0.session == .PM || $0.studentType == .alumni
            }
        case .fullDay:
            // This is the "full day" case or something has gone horribly wrong case
            studentsArray = students
        }
        
        studentsArray = studentsArray.sorted {
            ($0.indexNumber) < ($1.indexNumber)
        }
        
        // Remove students that are known to have attended already
        
        let attendedStudents: [Student] = lesson.attendances.compactMap({ att in
            
            return att.person
            
        })
        
        studentsArray = studentsArray.filter {
            !attendedStudents.contains($0)
        }
        switch search {
        case "":
            return studentsArray
        default:
            return studentsArray.filter { student in
                student.name.localizedCaseInsensitiveContains(search) || student.indexNumber.localizedCaseInsensitiveContains(search)
            }
        }
    }
    
    @State var search: String = ""
    @State var showMarkAlert = false
    @State var selectedStudent: Student?
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    if searchedStudents.count > 0 {
                        let students = searchedStudents.filter({$0.studentType == .student})
                        if students.count > 0 {
                            Section("Students") {
                                ForEach(students) { student in
                                    Button {
                                        selectedStudent = student
                                        showMarkAlert = true
                                    } label: {
                                        HStack {
                                            Text(student.indexNumber)
                                                .monospaced()
                                            Text(student.name)
                                            Spacer()
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                        let alumni = searchedStudents.filter({$0.studentType == .alumni})
                        
                        if alumni.count > 0 {
                            Section("Alumni") {
                                ForEach(alumni) { student in
                                    Button {
                                        selectedStudent = student
                                        showMarkAlert = true
                                    } label: {
                                        HStack {
                                            Text(student.indexNumber)
                                                .monospaced()
                                            Text(student.name)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // Search query returned no results
                        ContentUnavailableView("No Results Found", systemImage: "pc", description: Text("No results were found for this search query :("))
                            .symbolRenderingMode(.multicolor)
                    }
                    
                }.searchable(text: $search)
                
            }
            .alert(isPresented: $showMarkAlert) {
                Alert(title: Text("Attendance"),
                      message: Text("Mark \(selectedStudent?.name ?? "student") as attending?"),
                      primaryButton: .default(Text("Yes"), action: {
                    
                    guard let unwrappedSelectedStudent = selectedStudent else { return }

                    do {
                        try markAttendance(for: unwrappedSelectedStudent, forLesson: lesson, withContainer: mc.container)
                        try mc.save()
                    } catch {
                        print("Error whilst saving manual attendance: \(error.localizedDescription)")
                    }
                    dismiss()
                }), secondaryButton: .cancel())
            }
            .navigationTitle("Select Student")
        }
        
    }
}
