//
//  SettingsView.swift
//  CHEN
//
//  Created by Sean Wong on 29/2/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var moc
    @State var showExport = false
    @State var showImport = false
    @State var exportPath: URL = URL(string: "https://www.youtube.com/watch?v=_htnaGN8eOs")!
    var body: some View {
        VStack {
            
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
}

#Preview {
    SettingsView(exportPath: URL(string: "")!)
}
