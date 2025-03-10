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
    @State var currentType: StudentType = .student
    
    @State var showWarningAlert: Bool = false
    @State var studentToDelete: Student?
    var deletedStudent: Int = 0
    
    var searchedStudents: [Student] {
        switch search {
        case "":
            return students.filter { student in
                student.studentType == currentType
            }
        default:
            return students.filter { student in
                (student.name.localizedCaseInsensitiveContains(search) || student.indexNumber.localizedCaseInsensitiveContains(search)) && student.studentType == currentType
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
                        Picker("Student Type", selection: $currentType) {
                            Text("Student").tag(StudentType.student)
                            Text("Alumni").tag(StudentType.alumni)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        List {
                            if searchedStudents.count > 0 {
                                ForEach(searchedStudents) { student in
                                    StudentRowView(student: student)
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                studentToDelete = student
                                                showWarningAlert = true
                                                mc.delete(student)
                                            } label: {
                                                Text("Delete")
                                            }
                                        }
                                }
                            } else {
                                if currentType == .student {
                                    ContentUnavailableView("No Students", systemImage: "person.fill.questionmark")
                                } else {
                                    ContentUnavailableView("No Alumni", systemImage: "person.fill.questionmark")
                                }
                            }
                            
                        }
                        .searchable(text: $search)
                        .alert("Delete \(studentToDelete?.name ?? "Unknown Lesson")?",
                               isPresented: $showWarningAlert) {
                            Button("Cancel", role: .cancel) {
                                mc.rollback()
                            }
                            Button("Delete", role: .destructive) {

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
