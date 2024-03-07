//
//  LessonView.swift
//  CHEN
//
//  Created by Sean Wong on 1/10/23.
//

import SwiftUI

struct LessonView: View {
    
    @ObservedObject var lesson: Lesson
    @Environment(\.managedObjectContext) private var moc
    @State var showAlert = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    @State var searchTerm: String = ""
    
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
    var body: some View {
        VStack {
            Text("Lesson \(lesson.lessonLabel ?? "Unknown ID"): \(lesson.name ?? "Unknown Lesson")")
            Text(lesson.session ?? "Unknown Session")
            List {
                if filteredAttendances.count != 0 {
                    ForEach(filteredAttendances, id: \.id) { attendanceRecord in
                        HStack {
                            Text(attendanceRecord.person!.name!)
                            Spacer()
                            Text(dateFormatter.string(from: attendanceRecord.recordedAt!))
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            let attendance = filteredAttendances[index]
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
            .searchable(text: $searchTerm)
        }
        
    }
    
}

