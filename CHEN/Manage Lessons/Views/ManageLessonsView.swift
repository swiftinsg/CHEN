//
//  ManageLessonView.swift
//  CHEN
//
//  Created by Sean Wong on 4/9/23.
//

import SwiftUI

struct ManageLessonsView: View {
    @FetchRequest(sortDescriptors: [.init(keyPath: \Lesson.id, ascending: true)]) var lessons: FetchedResults<Lesson>
    @Environment(\.dismiss) private var dismiss
    @State var showAddLessonSheet = false
    var body: some View {
        NavigationStack {
            List(lessons) { lesson in
                NavigationLink {
                    LessonView(lesson: lesson)
                        .navigationTitle(lesson.name!)
                } label: {
                    Text(lesson.name ?? "Unknown Data")
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
                        showAddLessonSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddLessonSheet) {
                NavigationStack {
                    AddLessonSheet()
                        .navigationTitle(Text("Create Lesson"))
                }
            }
            .navigationTitle(Text("Lessons"))
        }
        
    }
}

