//
//  RecalculateStreaks.swift
//  CHEN
//
//  Created by Sean on 9/10/24.
//

import Foundation
import CoreData
import SwiftUI
import SwiftData

// TODO: rework this for SwiftData
@MainActor func reconstructStreakTimeline(deleting lesson: Lesson, withContainer container: ModelContainer) throws {
    
    let context = container.mainContext
    // Get list of "people affected", all of these people need their attendances recalculated
    // This is AM cohort for AM, PM for PM, all for full day
    let session = lesson.session.rawValue
    let fullDay = LessonSession.fullDay.rawValue
    let studentFetchDescriptor = FetchDescriptor<Student>(predicate: #Predicate<Student> { student in
        student._session == session || session == fullDay
    })
    var affectedStudents: [Student] = []
    do {
        affectedStudents = try context.fetch(studentFetchDescriptor)
    } catch {
        print(error.localizedDescription)
    }

    // Go through each student and adjust their attendances after the updated streak
    // Think about this a bit more
    for student in affectedStudents {
        
        var attendances = student.attendances
        
        // Sort attendances by lesson date, back to front 
        attendances.sort { att1, att2 in
            att1.forLesson!.date < att2.forLesson!.date
        }

        var attendancesToRecalculate: [Attendance] = []
        // If lesson not found
        if let deletedLessonAttendanceIndex = attendances.firstIndex(where: { att in
            att.forLesson == lesson
        }) {
            // Student attended lesson
            // Find index of deleted lesson, then recalculate streak from ONE lesson before to after
            if deletedLessonAttendanceIndex == attendances.count - 1 {
                attendances.remove(at: attendances.count-1)
                attendancesToRecalculate = attendances
            } else {
                let attendancesBefore = attendances[deletedLessonAttendanceIndex+1...attendances.count-1]
                let attendancesAfter = attendances[0..<deletedLessonAttendanceIndex]
                attendancesToRecalculate += attendancesBefore
                attendancesToRecalculate += attendancesAfter
            }
        } else {
            // Student did not attend lesson
            // Find where that lesson would have been, then select one lesson before and all lessons after and recalculate
            var attBefore = attendances.filter { att in
                att.forLesson!.date < lesson.date
            }
            let attAfter = attendances.filter { att in
                att.forLesson!.date > lesson.date
            }
            // If there are no lessons before or after, that means that the lesson being deleted would not have affected their streaks, so just return
            // Think about this and how it will affect the streak, right now deleting a streak and leaving no lessons AFTER also activates this when it shouldnt
            if attAfter.count == 0 {
                print("Streak did not change for \(student), returning")
                // Move on to next student, their streak did not change as the result of deleting this lesson
                continue
            }
            
            
            // else, just take all lessons after and one lesson before and recalculate streaks
            attBefore.sort { att1, att2 in
                att1.forLesson!.date > att2.forLesson!.date
            }
            
            // If there are attendances before this, we recalculate starting from the lesson before
            if let firstAtt = attBefore.first {
                attendancesToRecalculate += [firstAtt]
            }
            attendancesToRecalculate += attAfter
            
        }
        do {
            try recalculateStreaks(for: attendancesToRecalculate, withContainer: container)
        } catch {
            print(error.localizedDescription)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    context.delete(lesson)
}

@MainActor func reconstructStreakTimeline(inserting lesson: Lesson, withContainer container: ModelContainer) throws {

    let context = container.mainContext
    // Get list of "people affected", all of these people need their attendances recalculated
    // This is AM cohort for AM, PM for PM, all for full day
    let session = lesson.session.rawValue
    let fullDay = Session.fullDay.rawValue
    let studentFetchDescriptor = FetchDescriptor<Student>(predicate: #Predicate<Student> { student in
        student._session == session || session == fullDay
    })
    var affectedStudents: [Student] = []
    do {
        affectedStudents = try context.fetch(studentFetchDescriptor)
    } catch {
        print("Error whilst fetching affected students when reconstructing streak timeline: \(error.localizedDescription)")
    }
    // Go through each student and adjust their attendances after the updated streak
    // Think about this a bit more
    for student in affectedStudents {
        var attendances = student.attendances
        
        // Sort attendances by lesson date, back to front
        attendances.sort { att1, att2 in
            att1.forLesson!.date < att2.forLesson!.date
        }

        // Calculate attendances that need to be recalculated
        // Just consider all the lessons - if there are none after this lesson then no change in streaks
        // if this lesson is inserted in between others then recalculation is needed for all lessons AFTER (i.e. just break the streaks)
        
        let attsAfterAddedLesson = attendances.filter {
            $0.forLesson!.date > lesson.date
        }
        if attsAfterAddedLesson.count == 0 {
            // No attendances after added lesson, no need to recalc
            continue
        }
        do {
            try recalculateStreaks(for: attsAfterAddedLesson, withContainer: container)
        } catch {
            print("Error when recalculating streaks to reconstruct streak timeline: \(error.localizedDescription)")
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
