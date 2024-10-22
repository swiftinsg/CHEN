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

struct SettingsView: View {
    @ObservedObject var reader = NFCReader()
    
    @Environment(\.managedObjectContext) private var moc
    @State var showExport = false
    @State var showImport = false
    @State var exportPath: URL = URL(string: "https://www.youtube.com/watch?v=_htnaGN8eOs")!
    
    @State private var isAlertPresented = false
    @State private var studentName: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button("Check Card") {
                        studentName = nil
                        reader.read()
                    }
                }
                
                Section("Data") {
                    Button("Export Data") {
                        do {
                            let backupFile = try moc.persistentStoreCoordinator?.backupPersistentStore(atIndex: 0)
                            print("The backup is at \"\(String(describing: backupFile?.fileURL.path))\"")
                            // Do something with backupFile.fileURL
                            // Move it to a permanent location, send it to the cloud, etc.
                            // ...
                            if let file = backupFile {
                                exportPath = file.fileURL
                                showExport = true
                            }
                            
                        } catch {
                            print("Error backing up Core Data store: \(error)")
                        }
                    }
                    .fileImporter(isPresented: $showExport, allowedContentTypes: [.folder]) { result in
                        do {
                            // save the db file in this thing
                            
                            var saveURL = try result.get()
                            
                            let fileName = exportPath.lastPathComponent
                            saveURL.append(component: fileName)
                            print(saveURL)
                            // Get latest file name and append it to the save URL
                            try FileManager.default.copyItem(at: exportPath, to: saveURL)
                            // Delete temporary directory when done
                            try FileManager.default.removeItem(at: exportPath)
                            
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    Button("Import Data") {
                        
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
                    
                    let fetchRequest: NSFetchRequest<Student> = Student.fetchRequest()
                    fetchRequest.predicate = NSPredicate(
                        format: "%K == %@", "id", studentUUID as CVarArg
                    )
                    
                    do {
                        let students = try moc.fetch(fetchRequest)
                        guard let foundStudent = students.first else {
                            print("Student not found")
                            isAlertPresented = true
                            return
                        }
                        if let name = foundStudent.name {
                            studentName = name
                        }
                    } catch {
                        print("There was an error fetching the student: \(error)")
                    }
                    
                    isAlertPresented = true
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
