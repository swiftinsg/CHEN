//
//  RecalculateStreaks.swift
//  CHEN
//
//  Created by Sean on 10/10/24.
//

import Foundation
import SwiftUI
import CoreData

func recalculateStreaks(for student: Student, withContext moc: NSManagedObjectContext) throws {
    guard let studentAttendances = student.attendances else { throw "Student attendances do not exist" }
    var attendances = studentAttendances.allObjects.map {
        $0 as! Attendance
    }
    
    // reverse chronological order
    attendances.sort { att1, att2 in
        att1.forLesson!.date! < att2.forLesson!.date!
    }
    for att in attendances {
        do {
            try calculateStreak(for: att, withContext: moc)
        } catch {
            print(error.localizedDescription)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        
    }
    
    print(attendances)
}
