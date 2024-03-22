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
import CoreNFC
import AlertToast

struct ScanView: View {
    @ObservedObject var reader = NFCReader()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    
    @State var studentName: String = "Scan in a student!"
    @State var lesson: Lesson
    
    @State var alertToast: AlertToast = AlertToast(displayMode: .hud, type: .regular, title: "")
    @State var showChangeToast: Bool = false
    
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
                
                let attendances = lesson.attendances?.array as? [Attendance]
                
                Section("Marked attendance") {
                    ForEach(attendances ?? []) { attendance in
                        Text(attendance.person?.name ?? "")
                    }
                }
            }
            .nfcReader(isPresented: $isReaderPresented) { messages in
                guard let message = messages.first,
                      let record = message.records.first,
                      let studentUUID = UUID(uuidString: String(decoding: record.payload, as: UTF8.self)) else {
                    return "This is not a CHEN registered card."
                }
                
                let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
                
                fetchRequest.predicate = NSPredicate(
                    format: "%K == %@", "id", studentUUID as CVarArg
                )
                
                do {
                    let students = try moc.fetch(fetchRequest)
                    
                    guard let foundStudent = students.first else {
                        return "Student not found"
                    }
                    
                    if let name = foundStudent.name {
                        studentName = name
                        
                        // create attendance object
                        let attendance = Attendance(context: moc)
                        attendance.attendanceType = 1
                        attendance.forLesson = lesson
                        attendance.recordedAt = Date.now
                        
                        attendance.person = foundStudent
                        
                        try moc.save()
                        
                        return name
                    } else {
                        return "Student name not identified"
                    }
                } catch {
                    return "There was an error fetching the student: \(error)"
                }
            }
        }
        .navigationTitle(lesson.session ?? "")
        .toast(isPresenting: $showChangeToast, duration: 1.0) {
            alertToast
        }
    }
}



