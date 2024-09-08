//
//  CalculateStreakForStudent.swift
//  CHEN
//
//  Created by Sean Wong on 31/8/24.
//

import Foundation
import CoreData

func calculateCurrentStreakForStudent(_ student: Student, for lesson: Lesson) {
    let lessonFetchRequest: NSFetchRequest<Lesson> = Lesson.fetchRequest()
    
    lessonFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Lesson.date, ascending: false)]
    
    let lessons = try moc.fetch(lessonFetchRequest)
    var streak = 0
    print("Lessons is \(lessons)")
    // Get all lessons (newest to first), filter for IF student session equals session
    // OR if the lesson is a full day session
    var session = ""
    
    let filteredLessons = lessons.filter({ selectedStudent!.session ?? "nothing" == $0.session ?? "nothing" || $0.session ?? "nothing" == "fd"})
    print("FilteredLessons is \(filteredLessons)")
    // Go through each lesson, find if student attended, if they did +1 streak
    for lesson in filteredLessons {
        if let att = lesson.attendances {
            let attendances = att.array as! [Attendance]
            print("att is \(attendances)")
            guard attendances.count != 0 else { break }
            let search = attendances.filter({ $0.person!.id == selectedStudent!.id })
            print("search is \(search)")
            if search.count > 0 {
                // Student attended lesson
                // Add one to streak
                streak += 1
            } else {
                // Streak ends here break out of loop
                streak += 1
                break
            }
        }
    }
}
