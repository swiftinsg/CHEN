//
//  RecalculateStreaks.swift
//  CHEN
//
//  Created by Sean on 10/10/24.
//

import Foundation
import SwiftUI
import CoreData
import SwiftData

// TODO: rework this for SwiftData
@MainActor func recalculateStreaks(for attendances: [Attendance], withContainer container: ModelContainer) throws {
    
    var attendances = attendances
    print("recalc streaks called with \(attendances)")
    // reverse chronological order
    attendances.sort { att1, att2 in
        att1.forLesson!.date < att2.forLesson!.date
    }
    for att in attendances {
        do {
            try calculateStreak(for: att, withContainer: container)
        } catch {
            print("Error whilst recalculating streaks: \(error.localizedDescription)")
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    print(attendances)
}
