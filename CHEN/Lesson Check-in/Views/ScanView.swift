//
//  ScanView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import SwiftNFC
import CoreData
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
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(studentName)
                Button {
                    reader.read()
                } label: {
                    Text("Click here to scan")
                }
                NavigationLink() {
                    ManualAttendanceView(lesson: lesson, alertToast: $alertToast, showAlertToast: $showChangeToast)
                } label: {
                    Text("Manually mark a student as attending")
                }
                
            }
            
        }
        .onAppear {
            reader.startAlert = "Scanning..."
            reader.completionHandler = { (error) in
                
                // Handle error
                if let unwrappedError = error {
                    print(unwrappedError.localizedDescription)
                    print(unwrappedError)
                    return
                }
                
                let scannedID = reader.msg
                if scannedID == "Nothing scanned yet" { return }
                print("Card read: \(scannedID)")
                // Find individual
                
                // Sanitise the scanned UUID
                guard let studentUUID = UUID(uuidString: scannedID) else { reader.endAlert = "This isn't a CHEN enrolled card!"; return }
                
                let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
                fetchRequest.predicate = NSPredicate(
                    format: "%K == %@", "id", studentUUID as CVarArg
                )
                
                do {
                    let students = try moc.fetch(fetchRequest)
                    guard let foundStudent = students.first else {
                        print("Student not found")
                        return
                    }
                    if let name = foundStudent.name {
                        studentName = name
                        
                        // create attendance object
                        let attendance = Attendance(context: moc)
                        attendance.attendanceType = 1
                        attendance.forLesson = lesson
                        attendance.recordedAt = Date.now
                        
                        attendance.person = foundStudent
                        
                        reader.endAlert = "Welcome, \(name)"
                        try moc.save()
                    }
                } catch {
                    print("There was an error fetching the student: \(error)")
                }
            }
            //            .onChange(of: reader.msg) { oldID, scannedID in
            //                print(oldID)
            //                if scannedID == "Nothing scanned yet" { return }
            //                print("Card read: \(scannedID)")
            //                // Find individual
            //
            //                // Sanitise the scanned UUID
            //                guard let studentUUID = UUID(uuidString: scannedID) else { reader.endAlert = "This isn't a CHEN enrolled card!"; return }
            //                let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
            //                fetchRequest.predicate = NSPredicate(
            //                    format: "%K == %@", "id", studentUUID as CVarArg
            //                )
            //
            //                do {
            //                    let students = try moc.fetch(fetchRequest)
            //                    guard let foundStudent = students.first else {
            //                        print("Student not found")
            //                        return
            //                    }
            //                    if let name = foundStudent.name {
            //                        studentName = name
            //
            //                        // create attendance object
            //                        let attendance = Attendance(context: moc)
            //                        attendance.attendanceType = 1
            //                        attendance.forLesson = lesson
            //                        attendance.recordedAt = Date.now
            //
            //                        attendance.person = foundStudent
            //
            //                        reader.endAlert = "Welcome, \(name)"
            //                        try moc.save()
            //                    }
            //                } catch {
            //                    print("There was an error fetching the student: \(error)")
            //                }
        }
        .toast(isPresenting: $showChangeToast, duration: 1.0) {
            alertToast
        }
    }
}



