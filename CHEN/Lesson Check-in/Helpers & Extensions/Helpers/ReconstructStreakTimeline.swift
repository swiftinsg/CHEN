//
//  RecalculateStreaks.swift
//  CHEN
//
//  Created by Sean on 9/10/24.
//

import Foundation
import CoreData



func reconstructStreakTimeline(deleting lesson: Lesson, withContext moc: NSManagedObjectContext) throws {
    print(lesson)
    let session = lesson.session!
    
    // Get list of "people affected", all of these people need their attendances recalculated
    // This is AM cohort for AM, PM for PM, all for full day
    let studentFetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
    switch session.lowercased() {
    case "am", "pm":
        studentFetchRequest.predicate = NSPredicate(format: "%K == %@", "session", session)
    case "fd":
        // No need for predicate, get all students
        break
    default:
        // Error, something has gone wrong with lesson session
        throw "Invalid session when recalculating streaks: \(session)"
    }
    
    // Get students + list
    var affectedStudents: [Student] = []
    do {
        affectedStudents = try moc.fetch(studentFetchRequest)
    } catch {
        throw "Error when fetching students"
    }
    
    // Get current lessons from fetch request
    // The lesson to be deleted should not have been removed from context yet
    let lessonFetchRequest: NSFetchRequest<Lesson> = Lesson.fetchRequest()
    var lessons: [Lesson] = []
    do {
        lessons = try moc.fetch(lessonFetchRequest)
    } catch {
        throw "Error when fetching students"
    }
    
    let lessonIndex = lessons.firstIndex(of: lesson)
    
    // Go through each student and adjust their attendances after the updated streak
    // Think about this a bit more
    for student in affectedStudents {
        guard let att = student.attendances else { throw "Student has no attendances: \(student)" }
        var attendances = att.allObjects.map { attendance in
            attendance as? Attendance
        }
        
        // Sort attendances by
        
        print(attendances)
        
    }
}
