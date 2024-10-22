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
                .navigationTitle(lesson.name ?? "Unknown Lesson")
        } label: {
            HStack {
                Text(lesson.lessonLabel ?? "??")
                    .monospaced()
                    .padding(.trailing)
                switch lesson.session {
                case "AM":
                    Image(systemName: "sun.min")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.orange)
                        .frame(width: 24)
                case "PM":
                    Image(systemName: "sun.horizon")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.orange, .orange)
                        .frame(width:24)
                case "fd":
                    Image(systemName: "sun.haze")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.yellow, .orange)
                        .frame(width:24)
                default:
                    Image(systemName: "questionmark.app")
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text(lesson.name ?? "Unknown Data")
                    }
                    Text(lesson.session == "fd" ? "Full-day" : lesson.session ?? "No Session")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    
                }
            }
        }
    }
}
