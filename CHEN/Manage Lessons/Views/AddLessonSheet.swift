//
//  AddLessonSheet.swift
//  CHEN
//
//  Created by Sean Wong on 1/10/23.
//

import SwiftUI
import SwiftNFC
import SwiftData

struct AddLessonSheet: View {
    @Environment(\.dismiss) private var dismiss
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    @Environment(\.managedObjectContext) private var moc
    @State var name: String = ""
    @State var lessonLabel: String = ""
    @State var lessonSession: Session = .AM
    // Default to the current year
    @State var date: Date = Date()
    
    var body: some View {
        Form {
            Section("Lesson Name") {
                TextField("Structs, Classes & Closures", text: $name)
            }
            Section("Lesson Label") {
                TextField("3, 2A, 5B", text: $lessonLabel)
            }
            Section("Lesson Timing") {
                DatePicker(selection: $date) {
                    Text("Lesson Date")
                }
            }
            
            Section("Lesson Session") {
                Picker("Lesson Session", selection: $lessonSession) {
                    Text("AM").tag(Session.AM)
                    Text("PM").tag(Session.PM)
                    Text("Full-day").tag(Session.fullDay)
                }
                .pickerStyle(.segmented)
            }
            
            Button("Save Lesson") {
                
                // Recalc streaks after lesson creation
                let lesson = Lesson(date: date, id: UUID(), lessonLabel: lessonLabel, name: name, session: lessonSession)
                mc.insert(lesson)
                do {
                    try reconstructStreakTimeline(inserting: lesson, withContainer: mc.container)
                    try mc.save()
//                    try moc.save()
                    dismiss()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } catch {
                    print(error.localizedDescription)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
                
            }
            .disabled(name == "" || lessonLabel == "")
        }
        
    }
}
