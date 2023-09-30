//
//  PersonView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import SwiftNFC

struct PersonView: View {
    @ObservedObject var person: Person
    @ObservedObject var writer = NFCWriter()
    var body: some View {
        VStack {
            Text(person.name ?? "")
            Button("Associate Card with User") {
                if let personName = person.name, let personId = person.id {
                    
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

