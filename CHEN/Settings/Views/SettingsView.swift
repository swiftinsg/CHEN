//
//  SettingsView.swift
//  CHEN
//
//  Created by Sean Wong on 29/2/24.
//

import SwiftUI
import SwiftNFC
import CoreData
import CoreNFC
import SwiftData

struct SettingsView: View {
    @ObservedObject var reader = NFCReader()
    @Environment(\.modelContext) private var mc
    @State var showExport = false
    @State var showImport = false
    @State var exportPath: URL = URL(string: "https://www.youtube.com/watch?v=_htnaGN8eOs")!
    
    @State private var isScanning = false
    @State private var isAlertPresented = false
    @State private var studentName: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button("Check Card") {
                        studentName = nil

                        isScanning = true
                    }
                }
                .nfcReader(isPresented: $isScanning) { messages in
                    guard let message = messages.first,
                          let record = message.records.first, let studentUUID = UUID(uuidString: String(decoding: record.payload, as: UTF8.self)) else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        return "This is not a CHEN registered card."
                    }
                    
                    let studentFetchDescriptor = FetchDescriptor<Student>(predicate: #Predicate<Student> { student in
                        student.uuid == studentUUID
                    })
                    var students: [Student] = []
                    do {
                        students = try mc.fetch(studentFetchDescriptor)
                    } catch {
                        return error.localizedDescription
                    }
                    
                    // wait i had the list of students the whole time for the absentees list
                    guard let foundStudent = students.first(where: { student in
                        student.uuid == studentUUID
                    }) else {
                        return "Student not found"
                    }
                    
                    return foundStudent.name
                } onFailure: { err in
                    return "Error: \(err.localizedDescription)"
                }
                
                Section("Data") {
                    Text("SwiftData does not support exporting the entire db. This is a WIP.")
                        .bold()
                
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                reader.startAlert = "Scanning..."
                reader.endAlert = "Scanning complete!"
                reader.completionHandler = { (error) in
                    
                    // Handle error
                    if let unwrappedError = error {
                        print(unwrappedError.localizedDescription)
                        print(unwrappedError)
                        isAlertPresented = true
                        return
                    }
                    
                    let scannedID = reader.msg
                    if scannedID == "Nothing scanned yet" {
                        isAlertPresented = true
                        return
                    }
                    print("Card read: \(scannedID)")
                    // Find individual
                    
                    // Sanitise the scanned UUID
                    guard let studentUUID = UUID(uuidString: scannedID) else {
                        isAlertPresented = true
                        return
                    }
                    let fetchDescriptor = FetchDescriptor<Student>(predicate: #Predicate<Student> { student in
                        student.uuid == studentUUID
                    })
                    var students: [Student] = []
                    do {
                        students = try mc.fetch(fetchDescriptor)
                    } catch {
                        print(error.localizedDescription)
                        return
                    }
                    
        
                    guard let foundStudent = students.first else {
                        reader.endAlert = "Student not found"

                        return
                    }
                    studentName = foundStudent.name
                    reader.endAlert = studentName!

                }
            }
            .alert(studentName ?? "Student Not Found", isPresented: $isAlertPresented) {
                Button("OK") {
                }
            }
        }
    }
}

#Preview {
    SettingsView(exportPath: URL(string: "")!)
}
