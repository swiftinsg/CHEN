//
//  SelectLesson.swift
//  CHEN
//
//  Created by Sean Wong on 21/10/23.
//

import SwiftUI

struct SelectLessonView: View {
    @FetchRequest(sortDescriptors: [.init(keyPath: \Lesson.date, ascending: true)]) var lessons: FetchedResults<Lesson>
    
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
                                    ScanView(lesson: lesson)
                                } label: {
                                    Text(lesson.name ?? "Unknown Data")
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
