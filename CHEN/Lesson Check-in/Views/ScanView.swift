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

struct ScanView: View {
    @ObservedObject var reader = NFCReader()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var moc
    
    @State var studentName: String = "Nothing scanned yet"
    @State var lesson: Lesson
    
    var body: some View {
        VStack {
            Text(studentName)
            Button {
                reader.read()
            } label: {
                Text("Click here to scan")
            }
        }
        .onAppear {
            reader.startAlert = "Scanning..."
        }
        .onChange(of: reader.msg) { scannedID in
            if scannedID == "Nothing scanned yet" { return }
            print("Card read: \(scannedID)")
            // Find individual
            
            // Sanitise the scanned UUID
            guard let studentUUID = UUID(uuidString: scannedID) else { reader.endAlert = "This isn't a CHEN enrolled card!"; return }
            let fetchRequest: NSFetchRequest<Student>
            fetchRequest = Student.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@", "id", studentUUID as CVarArg
            )
            
            do {
                let students = try moc.fetch(fetchRequest)
                guard let foundStudent = students.first else { return }
                if let name = foundStudent.name {
                    studentName = name
                }
            } catch {
                print("There was an error fetching the student")
            }
        }
        
        
        
        
        // Add record for lesson for individual
        
    }
    
}

