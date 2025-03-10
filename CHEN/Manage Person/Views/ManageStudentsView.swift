//
//  ManagePersonView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import CoreData
import SwiftData

struct ManageStudentsView: View {
    
    @State private var bulkImportStudentPresented = false
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    @Environment(\.managedObjectContext) private var moc
    
    //    @FetchRequest(sortDescriptors: [.init(keyPath: \Student.indexNumber, ascending: true)]) var students: FetchedResults<Student>
    @Query(sort: \Student.indexNumber) var students: [Student]
    @State var showAddSheet: Bool = false
    
    @State var showWarningAlert: Bool = false
    @State var studentToDelete: Student?
    var deletedStudent: Int = 0
    
    var searchedStudents: [Student] {
        switch search {
        case "":
            return students
        default:
            return students.filter { student in
                student.name.localizedCaseInsensitiveContains(search) || student.indexNumber.localizedCaseInsensitiveContains(search)
            }
        }
    }
    
    @State var showDeleteAlert: Bool = false
    @State var search: String = ""
    
    var body: some View {
        NavigationStack {
            Group {
                VStack {
                    if students.count != 0 {
                        
                        List {
                            ForEach(searchedStudents) { student in
                                StudentRowView(student: student)
                            }
                            .onDelete(perform: { indexSet in
                                for index in indexSet {
                                    let students = students[index]
                                    
                                    studentToDelete = students
                                }
                                showWarningAlert = true
                            })
                            
                            
                        }
                        .searchable(text: $search)
                        .alert("Delete \(studentToDelete?.name ?? "Unknown Lesson")",
                               isPresented: $showWarningAlert) {
                            Button("Delete", role: .destructive) {
                                guard let studentToDelete else { return }
                                
                                mc.delete(studentToDelete)
                                //                            moc.delete(studentToDelete)
                                
                                do {
                                    try mc.save()
                                    //                                try moc.save()
                                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                                } catch {
                                    print(error.localizedDescription)
                                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                                }
                            }
                        } message: {
                            Text("This is irreversible.")
                        }
                        
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                EditButton()
                                Menu {
                                    Button {
                                        showAddSheet = true
                                    } label: {
                                        Label("Manually", systemImage: "person")
                                    }
                                    Button {
                                        bulkImportStudentPresented = true
                                    } label: {
                                        Label("From Spreadsheet", systemImage: "tablecells")
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                }
                                
                            }
                        }
                        
                        
                    } else {
                        ContentUnavailableView {
                            Label("No Students", systemImage: "person.fill.questionmark")
                        } actions: {
                            Menu {
                                Button {
                                    showAddSheet = true
                                } label: {
                                    Label("Manually", systemImage: "person")
                                }
                                Button {
                                    bulkImportStudentPresented = true
                                } label: {
                                    Label("From Spreadsheet", systemImage: "tablecells")
                                }
                            } label: {
                                Text("Add Student")
                            }
                            
                        }
                    }
                }
                .navigationTitle(Text("Students"))
            }
            .sheet(isPresented: $showAddSheet) {
                NavigationStack {
                    AddStudentSheet()
                        .navigationTitle("Create Student")
                }
            }
            .sheet(isPresented: $bulkImportStudentPresented) {
                BulkImportStudentView()
            }
        }
        
    }
}
