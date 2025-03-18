//
//  Attendance.swift
//  CHEN
//
//  Created by Sean on 8/3/25.
//
//

import Foundation
import SwiftData


@Model class Attendance {
    var attendanceType: Int16 = 0
    var recordedAt: Date = Date()
    var streak: Int16 = 0
    var streakStatus: StreakStatus {
        get { StreakStatus(rawValue: _streakStatus)! }
        set { _streakStatus = newValue.rawValue }
    }
    
    var _streakStatus: StreakStatus.RawValue = StreakStatus.other.rawValue
    
    var forLesson: Lesson?
    var person: Student?
    public init(recordedAt: Date, streak: Int16 = 0, streakStatus: StreakStatus = StreakStatus.other, forLesson: Lesson, person: Student) {
        self.recordedAt = recordedAt
        self.forLesson = forLesson
        self.person = person
        
        // Theese may not be set immediately upon object creation
        self.streak = streak
        self._streakStatus = streakStatus.rawValue
    }
    
    
    
}

enum StreakStatus: String, Codable {
    case added = "Added"
    case broke = "Broke"
    case initialised = "Initialised"
    
    // For alumni attendance - no streaking required
    case other = "Other"
}
