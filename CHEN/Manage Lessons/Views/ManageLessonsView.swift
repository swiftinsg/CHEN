//
//  ManageLessonView.swift
//  CHEN
//
//  Created by Sean Wong on 4/9/23.
//

import SwiftUI

struct ManageLessonsView: View {
    @FetchRequest(sortDescriptors: [.init(keyPath: \Lesson.session, ascending: true)]) var lessons: FetchedResults<Lesson>
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc

    @State private var showAddLessonSheet = false
    @State private var showWarningAlert = false
    @State private var lessonToDelete: Lesson?
    
    var body: some View {
        NavigationStack {
            let lessonDates: [Date] = Set(lessons.compactMap { lesson in
                if let date = lesson.date {
                    return Calendar.current.startOfDay(for: date)
                } else {
                    return nil
                }
            }).sorted(by: >)
            
            let sortedLessons = lessons.sorted { less1, less2 in
                less1.date! > less2.date!
            }
            List {
                ForEach(lessonDates, id: \.timeIntervalSince1970) { lessonDate in
                    Section(lessonDate.formatted(date: .abbreviated, time: .omitted)) {
                        
                        ForEach(sortedLessons, id: \.id) { lesson in
                            if let currentLessonDate = lesson.date,
                               Calendar.current.startOfDay(for: currentLessonDate) == lessonDate {
                                LessonRowView(lesson: lesson)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            print("indexes to be deleted \(indexSet)")
                            for index in indexSet {
                                let lesson = sortedLessons[index]
                                lessonToDelete = lesson
                                do {
                                    try reconstructStreakTimeline(deleting: lesson, withContext: moc)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            showWarningAlert = true
                        })
                        

                    }
                }
            }
            .alert("Delete \(lessonToDelete?.name ?? "Unknown Lesson")?",
                   isPresented: $showWarningAlert) {
                Button("Delete", role: .destructive) {  
                    do {
                        try moc.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                Button("Cancel", role: .cancel) {
                    moc.rollback()
                }
            } message: {
                Text("This is irreversible.")
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
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

