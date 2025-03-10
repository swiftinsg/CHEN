//
//  CHENApp.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI

@main
struct CHENApp: App {
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [Attendance.self, Lesson.self, Student.self])
    }
}
