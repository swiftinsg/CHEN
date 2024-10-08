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
    
    @State private var bulkImportStudentPresented = false
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(sortDescriptors: [.init(keyPath: \Student.indexNumber, ascending: true)]) var students: FetchedResults<Student>
    @State var showAddSheet: Bool = false
    
    @State var showWarningAlert: Bool = false
    @State var studentToDelete: Student?
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
                student.name!.localizedCaseInsensitiveContains(search) || student.indexNumber!.localizedCaseInsensitiveContains(search)
            }
        }
    }
    
    @State var showDeleteAlert: Bool = false
    @State var search: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {

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
                    .alert("Delete \(studentToDelete?.name ?? "Unknown Lesson")",
                           isPresented: $showWarningAlert) {
                        Button("Delete", role: .destructive) {
                            guard let studentToDelete else { return }
                            
                            moc.delete(studentToDelete)
                            
                            do {
                                try moc.save()
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            } catch {
                                print(error.localizedDescription)
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
        .sheet(isPresented: $bulkImportStudentPresented) {
            BulkImportStudentView()
        }
    }
}
