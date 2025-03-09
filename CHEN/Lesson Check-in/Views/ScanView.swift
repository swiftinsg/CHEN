//
//  ScanView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import SwiftNFC
import CoreData
import SwiftUINFC
import SwiftData
struct ScanView: View {
    @ObservedObject var reader = NFCReader()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    @State var studentName: String = "Scan in a student!"
    @State var lesson: Lesson
    
    @State private var isReaderPresented = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        isReaderPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "scanner")
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text("Scan Badge")
                                    .font(.headline)
                                Text("Tap to scan on a student's badge.")
                            }
                            .foregroundStyle(Color.primary)
                            Spacer()
                        }
                    }
                    NavigationLink {
                        ManualAttendanceView(lesson: lesson)
                    } label: {
                        Text("Manually mark a student as present")
                    }
                }
                
                Section("Marked attendance") {
                    ForEach(lesson.attendances ?? []) { attendance in
                        Text(attendance.person!.name)
                    }
                }
            }
            .nfcReader(isPresented: $isReaderPresented) { messages in
                guard let message = messages.first,
                      let record = message.records.first,
                      let studentUUID = UUID(uuidString: String(decoding: record.payload, as: UTF8.self)) else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    return "This is not a CHEN registered card."
                }
                
                //                let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
                //
                //                fetchRequest.predicate = NSPredicate(
                //                    format: "%K == %@", "id", studentUUID as CVarArg
                //                )
                

                let studentFetchDescriptor = FetchDescriptor<Student>(predicate: #Predicate<Student> { student in
                    student.uuid == studentUUID
                })
                do {
                    let students = try mc.fetch(studentFetchDescriptor)
                    guard let foundStudent = students.first else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        return "Student not found."
                    }
                    
                    studentName = foundStudent.name
                    
                    do {
                        try markAttendance(for: foundStudent, forLesson: lesson, withContainer: mc.container)
                        try mc.save()
                    } catch {
                        return error.localizedDescription
                    }
                    
                    return "Welcome, \(foundStudent.name)!"
                    
                } catch {
                    print(error.localizedDescription)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    return "There was an error scanning the student: \(error.localizedDescription)"
                }
                
            }
        }
        .navigationTitle(lesson.session.rawValue)
    }
}



