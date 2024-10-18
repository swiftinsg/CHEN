//
//  CaluclateStreak.swift
//  CHEN
//
//  Created by Sean on 10/10/24.
//

import Foundation
import SwiftUI
import CoreData

func calculateStreak(for attendance: Attendance, withContext moc: NSManagedObjectContext) throws {
    
    guard let student = attendance.person else { throw "Attendance not associated with a student" }
    guard let studentUUID = student.id else { throw "Student has an invalid UUID" }
    guard let lesson = attendance.forLesson else { throw "Attendance not associated with a lesson" }
    // Calc streak
    // Get last available attendance for user
    let attFetchRequest: NSFetchRequest<Attendance> = Attendance.fetchRequest()
    attFetchRequest.predicate = NSPredicate(format: "%K == %@", "id", studentUUID as CVarArg)
    attFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Attendance.recordedAt, ascending: false)]
    
    // At this point in time the attendance record should exist on MOC already as it's been added
    // Sort attendances by chronological order (1st entry = latest lesson)
    guard let studentAttendancesSet = student.attendances else { throw "Student attendances do not exist" }
    var studentAttendances = studentAttendancesSet.allObjects.map {
        $0 as! Attendance
    }
    studentAttendances.sort {
        $0.forLesson!.date! > $1.forLesson!.date!
    }
    
    // Get latest lesson
    
    let lessonFetchRequest: NSFetchRequest<Lesson> = Lesson.fetchRequest()
    
    let sessionPredicate = NSPredicate(format: "%K == %@", "session", student.session!)
    let fullDayPredicate = NSPredicate(format: "%K == %@", "session", "fd")
    let sessionOrFullDayPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [sessionPredicate, fullDayPredicate])
    lessonFetchRequest.predicate = sessionOrFullDayPredicate
    
    lessonFetchRequest.sortDescriptors = [.init(keyPath: \Lesson.date, ascending: false)]
    
    do {
        let lessons = try moc.fetch(lessonFetchRequest)
        if lessons.count > 1 {
            
            guard let lessonIndex = lessons.firstIndex(of: lesson) else { throw "Lesson not found in lessons list" }
            
            // If attendance is not in students' attendance index something is wrong
            guard let attendanceIndex = studentAttendances.firstIndex(of: attendance) else { throw "Attendance not found on student" }
            print("lessonIndex is \(lessonIndex)")
            
            // If this is not the first lesson
            if lessonIndex == lessons.count - 1 {
                attendance.streak = 1
                attendance.streakChangeReason = .initialised
                print("first CHRONOLOGICAL lesson, streak = 1 no matter what")
                return
            }
            

            if studentAttendances.count == 1 {
                // The student has no attendances before this add operation
                // Set attendance to 1 and move on
                attendance.streak = 1
                attendance.streakChangeReason = .initialised
                print("First attendance for student, streak set to 1")
                return
            } else if attendanceIndex == studentAttendances.count - 1 {
                // Student is trying to add an attendance that would be their first lesson - streak should be set to 1
                attendance.streak = 1
                attendance.streakChangeReason = .initialised
                print("New attendance would be oldest attendance for student - streak set to 1")
                return
            }
            
            guard let previousAttendedLesson = studentAttendances[attendanceIndex + 1].forLesson else { throw "Invalid lesson" }
            
            // lessons var contains CHRONOLOGICAL student session history (i.e, every session the student was supposed to attend)
            // if the LAST session the user was supposed to attend has an attendance for the student, keep up the streak
            // if not reset it
            let previousChronologicalLesson = lessons[lessonIndex + 1]

            if previousChronologicalLesson == previousAttendedLesson {
                let previousStreak = studentAttendances[attendanceIndex + 1].streak
                attendance.streak = previousStreak + 1
                print("Streak for \(attendance.forLesson!.name!) is \(previousStreak + 1)")
                attendance.streakChangeReason = .added
                print("added streak")
            } else {
                print("streak broke, set streak to 1")
                attendance.streakChangeReason = .broke
                attendance.streak = 1
            }
        } else {
            attendance.streak = 1
            attendance.streakChangeReason = .other
            print("this is the only lesson - set streak to 1")
        }
    } catch {
        print(error.localizedDescription)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
}
