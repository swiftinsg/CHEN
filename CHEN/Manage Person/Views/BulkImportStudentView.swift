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
    
    @Environment(\.managedObjectContext) private var moc
    
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
                Text(message)
            }
            .multilineTextAlignment(.center)
        }
    }
    
    func processImportedData() {
        withAnimation {
            state = .importing
        }
        
        guard let url else {
            state = .error("File URL not found")
            return
        }
        
        Task {
            guard url.startAccessingSecurityScopedResource() else {
                await MainActor.run {
                    state = .error("Could not access resource")
                }
                return
            }

            let contents: String
            do {
                contents = try String(contentsOf: url)
            } catch {
                await MainActor.run {
                    state = .error(error.localizedDescription)
                }
                return
            }
            
            url.stopAccessingSecurityScopedResource()
            
            var lines = contents.components(separatedBy: "\r\n")
            var includesStudentType = false
            
            let header = lines.removeFirst()
            
            if header == "name\tindexNumber\tsession\tbatch\ttype" {
                includesStudentType = true
            } else if header != "name\tindexNumber\tsession\tbatch" {
                await MainActor.run {
                    state = .error("File is not in the right format")
                }
                return
            }

            for (n, line) in lines.enumerated() {
                await MainActor.run {
                    currentRecord = n + 1
                }
                
                let data = line.components(separatedBy: "\t")
                let name = data[0]
                let indexNumber = data[1]
                let session = Session(rawValue: data[2]) ?? .AM
                let batch = Int16(data[3])!
                
                let newStudent = Student(uuid: UUID(), indexNumber: indexNumber, name: name, session: session, batch: batch)
                
                if includesStudentType {
                    let studentType = StudentType(rawValue: data[4]) ?? .student
                    newStudent.studentType = studentType
                    if studentType == .alumni { newStudent.session = .fullDay }
                }
                
                mc.insert(newStudent)
                
                do {
                    try mc.save()
                } catch {
                    await MainActor.run {
                        state = .error("Could not save student")
                    }
                }
            }
            
            await MainActor.run {
                state = .complete
            }
        }
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
