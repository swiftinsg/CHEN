//
//  CHENApp.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI



@main
struct CHENApp: App {
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
