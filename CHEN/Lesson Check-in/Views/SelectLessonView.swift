//
//  SelectLesson.swift
//  CHEN
//
//  Created by Sean Wong on 21/10/23.
//

import SwiftUI
import SwiftData
struct SelectLessonView: View {
    @Query(sort: \Lesson.date) var lessons: [Lesson]
//    @FetchRequest(sortDescriptors: [.init(keyPath: \Lesson.date, ascending: true)]) var lessons: FetchedResults<Lesson>
//    
    var body: some View {
        NavigationStack {
            let lessonDates: [Date] = Set(lessons.compactMap { lesson in
                Calendar.current.startOfDay(for: lesson.date)
            }).sorted(by: >)

            List {
                ForEach(lessonDates, id: \.timeIntervalSince1970) { lessonDate in
                    Section(lessonDate.formatted(date: .abbreviated, time: .omitted)) {
                        ForEach(lessons) { lesson in
                               if Calendar.current.startOfDay(for: lesson.date) == lessonDate {
                                NavigationLink {
                                    ScanView(lesson: lesson)
                                } label: {
                                    Text(lesson.name)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Lesson")
        }
        
    }
}

struct SelectLesson_Previews: PreviewProvider {
    static var previews: some View {
        SelectLessonView()
    }
}
