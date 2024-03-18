//
//  ManageLessonView.swift
//  CHEN
//
//  Created by Sean Wong on 4/9/23.
//

import SwiftUI

struct ManageLessonsView: View {
    @FetchRequest(sortDescriptors: [.init(keyPath: \Lesson.date, ascending: false)]) var lessons: FetchedResults<Lesson>
    @Environment(\.dismiss) private var dismiss
    @State var showAddLessonSheet = false
    var body: some View {
        NavigationStack {
            let lessonDates: [Date] = Set(lessons.compactMap { lesson in
                if let date = lesson.date {
                    return Calendar.current.startOfDay(for: date)
                } else {
                    return nil
                }
            }).sorted(by: >)
            
            List {
                ForEach(lessonDates, id: \.timeIntervalSince1970) { lessonDate in
                    Section(lessonDate.formatted(date: .abbreviated, time: .omitted)) {
                        ForEach(lessons) { lesson in
                            if let currentLessonDate = lesson.date,
                               Calendar.current.startOfDay(for: currentLessonDate) == lessonDate {
                                NavigationLink {
                                    LessonView(lesson: lesson)
                                        .navigationTitle(lesson.name!)
                                } label: {
                                    Text(lesson.name ?? "Unknown Data")
                                }
                            }
                        }
                    }
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

