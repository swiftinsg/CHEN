//
//  HomeView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            ManageLessonsView()
                .tabItem {
                    Label("Lessons", systemImage: "inset.filled.rectangle.and.person.filled")
                }
                .navigationTitle("Lessons")
            ManageStudentsView()
                .tabItem {
                    Label("Students", systemImage: "person.fill")
                }
                .navigationTitle("Students")
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

