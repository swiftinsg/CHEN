//
//  LessonView.swift
//  CHEN
//
//  Created by Sean Wong on 1/10/23.
//

import SwiftUI
import SwiftUINFC
import CoreData
import SwiftData

struct LessonView: View {
    
    @Bindable var lesson: Lesson
    @Environment(\.managedObjectContext) private var moc
    // TODO: Migrate CoreData transactions to SwiftData via modelContext
    @Environment(\.modelContext) private var mc
    @State var showAlert = false
    
    @State var searchTerm: String = ""
    @State var absenteeFilter: Session = .AM
    @State var attendanceFilter: StudentType = .student
    @Query(sort: \Student.indexNumber) var students: [Student]
    
    var filteredAttendances: [Attendance] {
        let attendances = lesson.attendances
        switch searchTerm {
        case "":
            return attendances
        default:
            return attendances.filter({ att in
                if let person = att.person {
                    return person.name.localizedCaseInsensitiveContains(searchTerm)
                } else {
                    // for this attendance, person doesn't exist???
                    return false
                }
            })
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
                .nfcReader(isPresented: $isReaderPresented) { msgs in
                    
                    guard let message = msgs.first,
                          let record = message.records.first, let studentUUID = UUID(uuidString: String(decoding: record.payload, as: UTF8.self)) else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        return "This is not a CHEN registered card."
                    }
                    
                    // wait i had the list of students the whole time for the absentees list
                    guard let foundStudent = students.first(where: { student in
                        student.uuid == studentUUID
                    }) else {
                        return "Student not found"
                    }
                    
                    do {
                        try markAttendance(for: foundStudent, forLesson: lesson, withContainer: mc.container)
                        try mc.save()
                    } catch {
                        print("An error occured: \(error.localizedDescription)")
                        return error.localizedDescription
                    }
                    
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    
                    return foundStudent.name
                }
                
                Section("Session Information") {
                    SessionInformationEditableField(title: "Name", placeholder: "Lesson Name", value: $lesson.name)
                    SessionInformationEditableField(title: "Lesson", placeholder: "1, 2A, etc.", value: $lesson.lessonLabel)
                    
                    HStack {
                        Text("Session")
                        Spacer()
                        
                        Text(formatSession())
                            .textSelection(.enabled)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section {
                let filteredSortedAttendances = filteredAttendances.sorted(by: {
                    ($0.person!.indexNumber) < ($1.person!.indexNumber)
                }).filter {
                        $0.person!.studentType == attendanceFilter
                    }
                
                if filteredSortedAttendances.count > 0 {
                    // filter again by student type
                    
                    ForEach(filteredSortedAttendances, id: \.id) { attendanceRecord in
                        StudentRowView(student: attendanceRecord.person!,
                                       attendance: attendanceRecord.recordedAt)
                    }
                    
                    .onDelete(perform: { indexSet in
                        
                        for index in indexSet {
                            let attendance = filteredSortedAttendances[index]
                            guard let student = attendance.person else {
                                // Student doesn't exist anymore?????
                                continue
                            }
                            mc.delete(attendance)
                            let attendancesToRecalculate = student.attendances
                            do {
                                if student.studentType == .student {
                                    try recalculateStreaks(for: attendancesToRecalculate, withContainer: mc.container)
                                }
                                try mc.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                        }
                        
                        
                        
                    })
                } else {
                    if searchTerm != "" {
                        // Search query returned no results
                        ContentUnavailableView("No Results Found", systemImage: "pc", description: Text("No results were found for this search query :("))
                            .symbolRenderingMode(.multicolor)
                    } else {
                        // Current attendance filter has no attendances
                        ContentUnavailableView("No Attendances", systemImage: "pc", description: Text("No \(attendanceFilter == .student ? "students" : "alumni") attended this class :("))
                            .symbolRenderingMode(.multicolor)
                    }
                }
            } header: {
                HStack {
                    Text("Attendances")
                    Spacer()
                    Picker("", selection: $attendanceFilter) {
                        Text("Student")
                            .tag(StudentType.student)
                        Text("Alumni")
                            .tag(StudentType.alumni)
                        
                    }
                    .textCase(.lowercase)
                }
                
            }
            
            if searchTerm.isEmpty {
                Section {
                    ForEach(students) { student in
                        if absenteeFilter == .fullDay || student.session == absenteeFilter {
                            
                            let contains = lesson.attendances.contains(where: { attendance in
                                attendance.person == student
                            })
                            
                            let alumni = student.studentType == .alumni
                            // if no contain AND is not alumni
                            if !contains && !alumni {
                                StudentRowView(student: student)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Student Absentees")
                        Spacer()
                        Picker("", selection: $absenteeFilter) {
                            Text("Morning")
                                .tag(Session.AM)
                            Text("Afternoon")
                                .tag(Session.PM)
                            Text("All")
                                .tag(Session.fullDay)
                        }
                        .textCase(.lowercase)
                    }
                }
            }
            
        }
        .searchable(text: $searchTerm)
        
    }
    func formatSession() -> String {
        var session = ""
        switch lesson.session {
        case .AM:
            session = "AM"
        case .PM:
            session = "PM"
        case .fullDay:
            session = "Full day"
        }
        return session
    }
}
