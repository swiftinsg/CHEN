//
//  SelectLesson.swift
//  CHEN
//
//  Created by Sean Wong on 21/10/23.
//

import SwiftUI

struct SelectLessonView: View {
    @FetchRequest(sortDescriptors: [.init(keyPath: \Lesson.id, ascending: true)]) var lessons: FetchedResults<Lesson>
    
    var body: some View {
        NavigationStack {
            List(lessons) { lesson in
                NavigationLink {
                    ScanView(lesson: lesson)
                } label: {
                    Text(lesson.name ?? "Unknown Data")
                }
            }
            .navigationTitle(Text("Select Lesson"))
        }
        
    }
}

struct SelectLesson_Previews: PreviewProvider {
    static var previews: some View {
        SelectLessonView()
    }
}
