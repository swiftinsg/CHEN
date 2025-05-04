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
    @Query var students: [Student]
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
                    ShareLink(item: exportStudentsLink()) {
                        Label("Export All Students", systemImage: "square.and.arrow.up")
                    }
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
    
    func exportStudentsLink() -> URL {
        var studentExports: [StudentExport] = []
        for student in students {
            var export = StudentExport()
            export.batch = Int(student.batch)
            export.cardID = student.cardID ?? ""
            export.indexNumber = student.indexNumber
            export.name = student.name
            export.session = student.session
            export.studentType = .student
            export.streak = Int(student.streak ?? 0)
            export.uuid = student.uuid
            studentExports.append(export)
            
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let exportData = try! JSONEncoder().encode(studentExports)
        print(String(data: exportData, encoding: .utf8)!)
        
        let temp = URL(filePath: FileManager.default.temporaryDirectory.path().appending("CHEN students.json"))
        print(temp.path())
        do {
            try exportData.write(to: temp, options: [.atomic, .completeFileProtection])
        } catch {
            print("ERROR" + error.localizedDescription)
        }
        
        return temp
    }
}

#Preview {
    SettingsView(exportPath: URL(string: "")!)
}
