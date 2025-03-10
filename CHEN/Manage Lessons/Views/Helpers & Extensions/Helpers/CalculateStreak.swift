//
//  CaluclateStreak.swift
//  CHEN
//
//  Created by Sean on 10/10/24.
//

import Foundation
import SwiftUI
import CoreData
import SwiftData

// TODO: rework this for SwiftData
@MainActor func calculateStreak(for attendance: Attendance, withContainer container: ModelContainer) throws {
    
    let context = container.mainContext
    guard let student = attendance.person, let lesson = attendance.forLesson else {
        throw "Student or lesson is nil - exiting early"
    }
    
    
    // Calc streak
    // Get last available attendance for user
    
    // At this point in time the attendance record should exist on MOC already as it's been added
    // Sort attendances by chronological order (1st entry = latest lesson)
    var studentAttendances = student.attendances

    studentAttendances.sort {
        $0.forLesson!.date > $1.forLesson!.date
    }
    
    let studentSession = student.session.rawValue
    let fullDay = Session.fullDay.rawValue
    // Get latest lesson
    let lessonFetchDescriptor = FetchDescriptor<Lesson>(predicate: #Predicate<Lesson> { lesson in
        lesson._session == studentSession || lesson._session == fullDay
    }, sortBy: [SortDescriptor(\Lesson.date, order: .reverse)])

    do {
        let lessons = try context.fetch(lessonFetchDescriptor)

        if lessons.count > 1 {

            guard let lessonIndex = lessons.firstIndex(of: lesson) else { throw "Lesson not found in lessons list" }
            // If attendance is not in students' attendance index something is wrong
            guard let attendanceIndex = studentAttendances.firstIndex(of: attendance) else { throw "Attendance not found on student" }
            print("lessonIndex is \(lessonIndex)")
            
            // If this is not the first lesson
            if lessonIndex == lessons.count - 1 {
                attendance.streak = 1
                attendance.streakStatus = .initialised
                print("first CHRONOLOGICAL lesson, streak = 1 no matter what")
                return
            }
            

            if studentAttendances.count == 1 {
                // The student has no attendances before this add operation
                // Set attendance to 1 and move on
                attendance.streak = 1
                attendance.streakStatus = .initialised
                print("First attendance for student, streak set to 1")
                return
            } else if attendanceIndex == studentAttendances.count - 1 {
                // Student is trying to add an attendance that would be their first lesson - streak should be set to 1
                attendance.streak = 1
                attendance.streakStatus = .initialised
                print("New attendance would be oldest attendance for student - streak set to 1")
                return
            }
            
            let previousAttendedLesson = studentAttendances[attendanceIndex + 1].forLesson
            
            // lessons var contains CHRONOLOGICAL student session history (i.e, every session the student was supposed to attend)
            // if the LAST session the user was supposed to attend has an attendance for the student, keep up the streak
            // if not reset it
            let previousChronologicalLesson = lessons[lessonIndex + 1]

            if previousChronologicalLesson == previousAttendedLesson {
                let previousStreak = studentAttendances[attendanceIndex + 1].streak
                attendance.streak = previousStreak + 1
                print("Streak for \(attendance.forLesson!.name) is \(previousStreak + 1)")
                attendance.streakStatus = .added
                print("added streak")
            } else {
                print("streak broke, set streak to 1")
                attendance.streakStatus = .broke
                attendance.streak = 1
            }
        } else {
            attendance.streak = 1
            attendance.streakStatus = .other
            print("this is the only lesson - set streak to 1")
        }
        context.insert(attendance)
    } catch {
        print("Error whilst recalculating individual streak: \(error.localizedDescription)")
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
}
