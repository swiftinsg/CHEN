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
            
            List {
                ForEach(lessonDates, id: \.timeIntervalSince1970) { lessonDate in
                    Section(lessonDate.formatted(date: .abbreviated, time: .omitted)) {
                        ForEach(lessons) { lesson in
                            if let currentLessonDate = lesson.date,
                               Calendar.current.startOfDay(for: currentLessonDate) == lessonDate {
                                LessonRowView(lesson: lesson)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            for index in indexSet {
                                let lesson = lessons[index]
                                
                                lessonToDelete = lesson
                            }
                            
                            showWarningAlert = true
                        })
                        .alert("Delete \(lessonToDelete?.name ?? "Unknown Lesson")",
                               isPresented: $showWarningAlert) {
                            Button("Delete", role: .destructive) {
                                guard let lessonToDelete else { return }
                                
                                for attendance in lessonToDelete.attendances?.array as? [Attendance] ?? []  {
                                    moc.delete(attendance)
                                }
                                moc.delete(lessonToDelete)
                                
                                do {
                                    try moc.save()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        } message: {
                            Text("This is irreversible.")
                        }

                    }
                }
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

