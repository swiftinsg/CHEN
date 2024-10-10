//
//  Attendance+StreakStatus.swift
//  CHEN
//
//  Created by Sean on 10/10/24.
//

import Foundation
import CoreData

extension Attendance {
    var streakChangeReason: StreakStatus {
        get {
            return StreakStatus(rawValue: self.streakStatus ?? "Other") ?? .other
        }
        set {
            self.streakStatus = newValue.rawValue
        }
    }
}
