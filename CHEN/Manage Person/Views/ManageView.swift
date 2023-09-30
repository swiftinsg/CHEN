//
//  ManageStudentsView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import CoreData
struct ManageView: View {
    @FetchRequest(sortDescriptors: [.init(keyPath: \Person.id, ascending: true)]) var people: FetchedResults<Person>
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List(people) { person in
                NavigationLink {
                    PersonView(person: person)
                } label: {
                    Text(person.name ?? "Unknown Data")
                }
                
            }
        }
        
    }
}
