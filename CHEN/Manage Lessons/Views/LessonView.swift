//
//  LessonView.swift
//  CHEN
//
//  Created by Sean Wong on 1/10/23.
//

import SwiftUI

struct LessonView: View {
    @ObservedObject var lesson: Lesson
    var body: some View {
        Text("Lesson \(lesson.lessonLabel ?? "Unknown ID"): \(lesson.name ?? "Unknown Lesson")")
    }
}

