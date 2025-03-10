//
//  LessonRowView.swift
//  CHEN
//
//  Created by Jia Chen Yee on 20/3/24.
//

import SwiftUI

struct LessonRowView: View {
    
    @Bindable var lesson: Lesson
    
    var date: Date?
    
    var body: some View {
        NavigationLink {
            // Instantiate absentee filter state upon view creation
            LessonView(lesson: lesson, absenteeFilter: lesson.session)
                .navigationTitle(lesson.name)
        } label: {
            HStack {
                Text(lesson.lessonLabel)
                    .monospaced()
                    .padding(.trailing)
                switch lesson.session {
                case .AM:
                    Image(systemName: "sun.min")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.orange)
                        .frame(width: 24)
                case .PM:
                    Image(systemName: "sun.horizon")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.orange, .orange)
                        .frame(width:24)
                case .fullDay:
                    Image(systemName: "sun.haze")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.yellow, .orange)
                        .frame(width:24)
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text(lesson.name)
                    }
                    Text(lesson.session == .fullDay ? "Full-day" : lesson.session.rawValue)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    
                }
            }
        }
    }
}
