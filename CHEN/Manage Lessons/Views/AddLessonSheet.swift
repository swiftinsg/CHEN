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
            Button("Save Lesson") {
                let lesson = Lesson(context:moc)
                lesson.id = UUID()
                lesson.name = name
                lesson.date = date
                lesson.lessonLabel = lessonLabel
                do {
                    try moc.save()
                } catch {
                    print("An error occured whilst saving the new lesson.")
                }
                dismiss()
            }
        }
        
    }
}
