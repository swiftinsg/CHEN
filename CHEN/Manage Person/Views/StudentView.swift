//
//  PersonView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import SwiftNFC

struct StudentView: View {
    @ObservedObject var student: Student
    @ObservedObject var writer = NFCWriter()
    var body: some View {
        VStack {
            Text(student.name ?? "")
            Button("Associate Card with User") {
                if let personName = student.name {
                    
                    let writeText = "\(personName)"
                    writer.msg = writeText
                    writer.write()
                    
                }

            }
            .padding()
            .buttonStyle(.borderedProminent)
        }
        
    }
}

