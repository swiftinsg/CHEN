//
//  LessonRowView.swift
//  CHEN
//
//  Created by Jia Chen Yee on 20/3/24.
//

import SwiftUI

struct LessonRowView: View {
    
    @ObservedObject var lesson: Lesson
    
    var date: Date?
    
    var body: some View {
        NavigationLink {
            LessonView(lesson: lesson)
                .navigationTitle(lesson.name!)
        } label: {
            HStack {
                Text(lesson.lessonLabel ?? "")
                    .monospaced()
                    .padding(.trailing)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: lesson.session == "AM" ? "sun.horizon" : "sun.max")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(lesson.session == "AM" ? .primary : Color.orange, .orange)
                            .frame(width: 24)
                        Text(lesson.name ?? "Unknown Data")
                        
                        Spacer()
                        
                        if let date {
                            Text(date.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    Text(lesson.session ?? "No Session")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
    }
}
