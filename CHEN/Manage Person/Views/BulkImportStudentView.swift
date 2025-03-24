//
//  BulkImportStudentView.swift
//  CHEN
//
//  Created by Jia Chen Yee on 8/3/24.
//

import SwiftUI
import SwiftData

struct BulkImportStudentView: View {
    
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    
    @Environment(\.dismiss) private var dismiss
    @State private var state = ImportState.selectingFile
    
    @State private var url: URL?
    @State private var isImporterPresented = false
    
    @State private var currentRecord = 0
    
    var body: some View {
        switch state {
        case .selectingFile:
            NavigationStack {
                Form {
                    Section {
                        Button {
                            isImporterPresented.toggle()
                        } label: {
                            Label(url == nil ? "Choose from Files" : "Change File", systemImage: "doc.text")
                        }
                    } footer: {
                        VStack {
                            Text("""
                                 Choose a .tsv file formatted with exactly 4 columns:
                                 **`name`, `indexNumber`, `session`, `batch`**,
                                 OR exactly 5 columns:
                                 **`name`, `indexNumber`, `session`, `batch`, `type`**.
                                 
                                 `type` should be exactly **`Student`** or **`Alumni`**.
                                 `session` should be either **`AM`** or **`PM`**. This field is ignored if the record's `type` is **`Alumni`**.
                                 """)
                        }
                        
                    }
                    .fileImporter(isPresented: $isImporterPresented,
                                  allowedContentTypes: [.tabSeparatedText]) { result in
                        switch result {
                        case .success(let success):
                            url = success
                        case .failure(let failure):
                            print(failure.localizedDescription)
                        }
                    }
                    
                    if let url {
                        Section("Selected File") {
                            Text(url.lastPathComponent)
                        }
                        Button("Import") {
                            processImportedData()
                        }
                    }
                }
                .navigationTitle("Bulk Import Students")
            }
        case .importing:
            VStack(alignment: .center) {
                Spacer()
                ProgressView()
                    .padding(.bottom)
                Text("Importing Data…")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Please do not close this app.")
                Spacer()
                Text("Processing record #\(currentRecord)...")
            }
            .multilineTextAlignment(.center)
        case .complete:
            VStack(alignment: .center) {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(Color.accentColor)
                    .font(.largeTitle)
                Text("Imported \(currentRecord) records.")
                    .padding(.horizontal)
                    .font(.title)
                    .fontWeight(.bold)
                Button("Done") {
                    dismiss()
                }
            }
            .multilineTextAlignment(.center)
        case .error(let message):
            VStack(alignment: .center) {
                Image(systemName: "pc")
                    .symbolRenderingMode(.multicolor)
                    .font(.largeTitle)
                Text("Import Failed")
                    .font(.title)
                    .fontWeight(.bold)
                Text(.init(message))
                    .padding(.horizontal)
                Button("Done") {
                    dismiss()
                }
            }
            .multilineTextAlignment(.center)
        }
    }
    
    func processImportedData() {
        
        // I would transaction this but there's some stupid async stuff I don't want to deal with
        mc.autosaveEnabled = false
        
        withAnimation {
            state = .importing
        }
        
        guard let url else {
            state = .error("File URL not found")
            return
        }
        
        Task {
            guard url.startAccessingSecurityScopedResource() else {
                state = .error("Could not access resource")
                return
            }
            
            let contents: String
            do {
                contents = try String(contentsOf: url)
            } catch {
                abortImport(withReason: error.localizedDescription)
                return
            }
            
            url.stopAccessingSecurityScopedResource()
            
            var lines = contents.components(separatedBy: "\r\n")
            var includesStudentType = false
            
            let header = lines.removeFirst()
            
            if header == "name\tindexNumber\tsession\tbatch\ttype" {
                includesStudentType = true
            } else if header != "name\tindexNumber\tsession\tbatch" {
                abortImport(withReason: "File contains an incorrect header format.")
                return
            }
            
            func formatBlank(_ input: String) -> String {
                if input.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    return "[blank]"
                } else {
                    return input
                }
            }
            
            for (n, line) in lines.enumerated() {
                await MainActor.run {
                    currentRecord = n + 1
                }
                
                let data = line.components(separatedBy: "\t")
                let name = data[0]
                let indexNumber = data[1]
                
                // Assume record is a student record first
                var studentType: StudentType = .student
                // If has student type included in record, validate student type
                if includesStudentType, let unwrappedStudentType = StudentType(rawValue: data[4]) {
                    studentType = unwrappedStudentType
                } else {
                    if data.count == 4 && includesStudentType {
                        abortImport(withReason: "File is not in the right format: file should include student type but is missing it on line `\(n+2)`.")
                        return
                    }
                    if data.count >= 5 && includesStudentType {
                        abortImport(withReason: "File is not in the right format: incorrect student type on line `\(n+2)`: `\(formatBlank(data[4]))`")
                        return
                    }
                    // if does not include student type we expect 4 length in data so it's not an error
                }
                
                // Assume "fullday" session first (i.e. no session)
                var session: Session = .fullDay
                
                // don't set student session if alumni, but if it's regular student unpack it properly
                if studentType == .student, let unwrappedSession = Session(rawValue: data[2]) {
                    session = unwrappedSession
                } else {
                    if !includesStudentType || studentType == .student {
                        
                        abortImport(withReason: "File is not in the right format: incorrect student session on line `\(n+2)`: `\(formatBlank(data[2]))`")
                        return
                    }
                    
                }
                
                guard let batch = Int16(data[3]) else {
                    abortImport(withReason: "File is not in the right format: invalid student batch on line `\(n+2)`: `\(formatBlank(data[3]))`")
                    return
                }
                
                let newStudent = Student(uuid: UUID(), indexNumber: indexNumber, name: name, session: session, batch: batch, studentType: studentType)
                
                mc.insert(newStudent)
                
            }
            
            do {
                try mc.save()
            } catch {
                abortImport(withReason: "Could not save student.")
                return
            }
            
            state = .complete
            
        }
        
        // re-enable autosave
        mc.autosaveEnabled = true
    }
    
    // View implies MainActor, no need to specify to run on MainActor
    func abortImport(withReason reason: String) {
        state = .error(reason)
        mc.rollback()
    }
    
    enum ImportState {
        case selectingFile
        case importing
        case complete
        case error(String)
    }
}

#Preview {
    BulkImportStudentView()
}
