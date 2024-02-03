//
//  ManagePersonView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import CoreData
import AlertToast

struct ManageStudentsView: View {
    @FetchRequest(sortDescriptors: [.init(keyPath: \Student.id, ascending: true)]) var students: FetchedResults<Student>
    @State var showAddSheet: Bool = false
    var deletedStudent: Int = 0
    
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
    
    @State var showDeleteAlert: Bool = false
    @State var search: String = ""
    @State var alertToast: AlertToast = AlertToast(displayMode: .hud, type: .regular, title: "Sample Alert")
    @State var showChangeToast: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Implement searches properly (see LessonView)
                    List(searchedStudents) { student in
                        NavigationLink {
                            StudentView(student: student)
                        } label: {
                            Text(student.name ?? "Unknown Data")
                        }
                        
                        .swipeActions {
                            NavigationStack {
                                NavigationLink {
                                    EditStudentView(student: student, alertToast: $alertToast, showChangeToast: $showChangeToast)
                                        .navigationTitle("Edit Student")
                                } label: {
                                    Button {
                                        
                                    } label: {
                                        Text("Edit")
                                    }
                                    
                                }
                                
                                
                            }
                            Button(role: .destructive) {
                                print("delete button pressed")
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            EditButton()
                            Button {
                                showAddSheet = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $showAddSheet) {
                        NavigationStack {
                            AddStudentSheet(showChangeToast: $showChangeToast, alertToast: $alertToast)
                                .navigationTitle("Create Student")
                        }
                    }
                    .searchable(text: $search)
                }
            }.navigationTitle(Text("Students"))
        }
        .toast(isPresenting: $showChangeToast, alert: {
            alertToast
        })
        
    }
}
