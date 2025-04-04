//
//  ManageLessonView.swift
//  CHEN
//
//  Created by Sean Wong on 4/9/23.
//

import SwiftUI
import SwiftData
struct ManageLessonsView: View {
    @Query(sort: \Lesson.lessonLabel) var lessons: [Lesson]
    @Environment(\.dismiss) private var dismiss
    
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    @State private var showAddLessonSheet = false
    @State private var showWarningAlert = false
    @State private var lessonToDelete: Lesson?
    
    var body: some View {
        NavigationStack {
            let lessonDates: [Date] = Set(lessons.compactMap { lesson in
                return Calendar.current.startOfDay(for: lesson.date)
            }).sorted(by: >)
            
            let sortedLessons = lessons.sorted { less1, less2 in
                less1.date > less2.date
            }
            Group {
                if lessonDates.count != 0 {
                    List {
                        ForEach(lessonDates, id: \.timeIntervalSince1970) { lessonDate in
                            Section(lessonDate.formatted(date: .abbreviated, time: .omitted)) {
                                
                                ForEach(sortedLessons, id: \.id) { lesson in
                                    let currentLessonDate = lesson.date
                                    if Calendar.current.startOfDay(for: currentLessonDate) == lessonDate {
                                        LessonRowView(lesson: lesson)
                                            .swipeActions {
                                                Button(role: .destructive) {
                                                    
                                                    lessonToDelete = lesson
                                                    showWarningAlert = true
                                                    mc.autosaveEnabled = false
                                                    do {
                                                        try reconstructStreakTimeline(deleting: lesson, withContainer: mc.container)
                                                        
                                                    } catch {
                                                        print(error.localizedDescription)
                                                    }
                                                } label: {
                                                    Text("Delete")
                                                }
                                            }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button {
                                showAddLessonSheet = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                } else {
                    ContentUnavailableView {
                        Label("No Lessons", systemImage: "questionmark.folder")
                    } actions: {
                        Button {
                            showAddLessonSheet = true
                        } label: {
                            Text("Add Lesson")
                        }
                    }
                }
                
            }
            .alert("Delete \(lessonToDelete?.name ?? "Unknown Lesson")?",
                   isPresented: $showWarningAlert) {
                Button("Delete", role: .destructive) {
                    do {
                        try mc.save()
                        mc.autosaveEnabled = true
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                Button("Cancel", role: .cancel) {
                    mc.rollback()
                }
            } message: {
                Text("This is irreversible.")
            }
            .sheet(isPresented: $showAddLessonSheet, content: {
                NavigationStack {
                    AddLessonSheet()
                        .navigationTitle(Text("Create Lesson"))
                }
                
            })
            .navigationTitle(Text("Lessons"))
        }
        
        
    }
    
    
    
}






