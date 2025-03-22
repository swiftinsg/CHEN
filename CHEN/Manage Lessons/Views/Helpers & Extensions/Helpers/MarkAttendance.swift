//
//  MarkAttendance.swift
//  CHEN
//
//  Created by Sean on 9/3/25.
//

import SwiftData
import SwiftUI
import Foundation
@MainActor
func markAttendance(for student: Student, forLesson lesson: Lesson, withContainer container: ModelContainer) throws {
    
    let context = container.mainContext
    
    // create attendance object
    
    let attendance = Attendance(recordedAt: .now, forLesson: lesson, person: student)

    context.insert(attendance)
    try context.save()
    
    // If student is alumni just exit no need to calculate streaks
    if student.studentType == .alumni {
        return
    }
    
    let studentAttendedLessonsSet = student.attendances
    var studentAttendedLessons: [Lesson] = studentAttendedLessonsSet.compactMap {
        let att = $0
        return att.forLesson
    }
    // Calc streak
    // Check if there are attended lessons AFTER this lesson
    // If so they need to be recalculated
    // Streak history before this is not affected
    studentAttendedLessons = studentAttendedLessons.filter {
        $0.date > lesson.date
    }

    if studentAttendedLessons.count > 0 {
        // Recalculate ALL streaks (may bridge two streaks together)
        
        let studentAttendances = student.attendances
        try recalculateStreaks(for: studentAttendances, withContainer: container)
        try context.save()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    } else if student.studentType == .student {
        // This incoming streak is the latest, calculate it as per normal
        
        try calculateStreak(for: attendance, withContainer: container)
        try context.save()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
    }
    
}
