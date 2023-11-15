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
    
    @State var showDeleteAlert: Bool = false
    
    @State var alertToast: AlertToast = AlertToast(displayMode: .hud, type: .regular, title: "Sample Alert")
    @State var showChangeToast: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List(students) { student in
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
                }
            }.navigationTitle(Text("Students"))
        }
        .toast(isPresenting: $showChangeToast, alert: {
            alertToast
        })
        
    }
}