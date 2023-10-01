//
//  ManagePersonView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import CoreData
struct ManageStudentsView: View {
    @FetchRequest(sortDescriptors: [.init(keyPath: \Student.id, ascending: true)]) var students: FetchedResults<Student>
    @State var showAddSheet: Bool = false
    var body: some View {
        NavigationStack {
            
            VStack {
                List(students) { student in
                    NavigationLink {
                        StudentView(student: student)
                    } label: {
                        Text(student.name ?? "Unknown Data")
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            print("Edit button pressed")
                        } label: {
                            Image(systemName: "pencil.line")
                        }
                        Button {
                            showAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddSheet) {
                    NavigationStack {
                        AddStudentSheet()
                            .navigationTitle(Text("Create Student"))
                    }   
                }
                .navigationTitle(Text("Students"))
            }
        }
    }
}
