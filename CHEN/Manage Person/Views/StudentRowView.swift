//
//  StudentRowView.swift
//  CHEN
//
//  Created by Jia Chen Yee on 20/3/24.
//

import SwiftUI

struct StudentRowView: View {
    
    @Bindable var student: Student
    var attendance: Date?
    
    var body: some View {
        NavigationLink {
            StudentView(student: student)
        } label: {
            HStack {
                
                Text(student.indexNumber)
                    .monospaced()
                Text(student.name)
                Spacer()
                
                if let attendance {
                    Text(attendance.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}
