//
//  GenerateView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import CoreData
struct GenerateView: View {
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        VStack {
            Button("Add Person") {
                let person = Person(context:moc)
                person.id = UUID()
                person.name = "Sean Wong"
                
                try? moc.save()


            }
            Button("Add Lesson") {
                
            }
        }
        
        
    }
}

struct GenerateView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateView()
    }
}
