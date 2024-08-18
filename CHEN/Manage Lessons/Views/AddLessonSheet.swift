//
//  AddLessonSheet.swift
//  CHEN
//
//  Created by Sean Wong on 1/10/23.
//

import SwiftUI
import SwiftNFC

struct AddLessonSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    @State var name: String = ""
    @State var lessonLabel: String = ""
    @State var lessonSession: String = "AM"
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
                    Text("AM").tag("AM")
                    Text("PM").tag("PM")
                    Text("Full-day").tag("fd")
                }.pickerStyle(.segmented)
            }
            Button("Save Lesson") {
                let lesson = Lesson(context:moc)
                lesson.id = UUID()
                lesson.name = name
                lesson.date = date
                lesson.lessonLabel = lessonLabel
                lesson.session = lessonSession
                do {
                    try moc.save()
                    dismiss()
                } catch {
                    print("An error occured whilst saving the new lesson.")
                }
                
            }
        }
        
    }
}
