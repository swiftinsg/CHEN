//
//  LessonView.swift
//  CHEN
//
//  Created by Sean Wong on 1/10/23.
//

import SwiftUI
import SwiftUINFC
import CoreData

struct LessonView: View {
    
    @ObservedObject var lesson: Lesson
    @Environment(\.managedObjectContext) private var moc
    @State var showAlert = false
    
    @State var searchTerm: String = ""
    @State var absenteeFilter: String = "Morning"
    
    
    @FetchRequest(sortDescriptors: [.init(keyPath: \Student.indexNumber, ascending: true)]) var students: FetchedResults<Student>
    
    var filteredAttendances: [Attendance] {
        let attendances = lesson.attendances!.array as? [Attendance]
        switch searchTerm {
        case "":
            return attendances ?? []
        default:
            return attendances?.filter({ att in
                att.person!.name!.localizedCaseInsensitiveContains(searchTerm)
            }) ?? []
        }
    }
    
    @State private var isReaderPresented = false
    
    var body: some View {
        List {
            if searchTerm.isEmpty {
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
                .nfcReader(isPresented: $isReaderPresented) { messages in
                    guard let message = messages.first,
                          let record = message.records.first,
                          let studentUUID = UUID(uuidString: String(decoding: record.payload, as: UTF8.self)) else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
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
                            let attendance = Attendance(context: moc)
                            attendance.attendanceType = 1
                            attendance.forLesson = lesson
                            attendance.recordedAt = Date.now
                            
                            attendance.person = foundStudent
                            
                            try moc.save()
                            
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            
                            return name
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            return "Student name not identified"
                        }
                    } catch {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        return "There was an error fetching the student: \(error)"
                    }
                }
                
                Section("Session Information") {
                    SessionInformationEditableField(title: "Name", placeholder: "Lesson Name", value: $lesson.name)
                    SessionInformationEditableField(title: "Lesson", placeholder: "1, 2A, etc.", value: $lesson.lessonLabel)
                    
                    HStack {
                        Text("Session")
                        Spacer()
                        Text(lesson.session ?? "Unknown")
                            .textSelection(.enabled)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Attendances") {
                if filteredAttendances.count != 0 {
                    let filteredSortedAttendance = filteredAttendances.sorted(by: {
                        ($0.person?.indexNumber ?? "") < ($1.person?.indexNumber ?? "")
                    })
                    
                    ForEach(filteredSortedAttendance, id: \.id) { attendanceRecord in
                        StudentRowView(student: attendanceRecord.person!,
                                       attendance: attendanceRecord.recordedAt!)
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            let attendance = filteredSortedAttendance[index]
                            moc.delete(attendance)
                        }
                        do {
                            try moc.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    })
                } else {
                    if (lesson.attendances!.array as? [Attendance])!.count == 0 {
                        ContentUnavailableView("No Attendances", systemImage: "pc", description: Text("No one attended this class :("))
                            .symbolRenderingMode(.multicolor)
                    } else {
                        // Search query returned no results
                        ContentUnavailableView("No Results Found", systemImage: "pc", description: Text("No results were found for this search query :("))
                            .symbolRenderingMode(.multicolor)
                    }
                }
            }
            
            if searchTerm.isEmpty {
                Section {
                    ForEach(students) { student in
                        if absenteeFilter == "all" || student.session == absenteeFilter {
                            
                            let contains = ((lesson.attendances?.array as? [Attendance]) ?? []).contains(where: { attendance in
                                attendance.person == student
                            })
                            
                            if !contains {
                                StudentRowView(student: student)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Absentees")
                        Spacer()
                        Picker("", selection: $absenteeFilter) {
                            Text("Morning")
                                .tag("Morning")
                            Text("Afternoon")
                                .tag("Afternoon")
                            Text("All")
                                .tag("All")
                        }
                        .textCase(.lowercase)
                    }
                }
            }
            
        }
        .searchable(text: $searchTerm)
        .onAppear {
            switch lesson.session ?? "AM" {
            case "AM":
                absenteeFilter = "Morning"
                break
            case "PM":
                absenteeFilter = "Afternoon"
                break
            case "All-day":
                absenteeFilter = "All"
                break
            default:
                break
            }
            
        }
    }
    
}

