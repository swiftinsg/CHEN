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
            
                SelectLessonView()
                    .tabItem {
                        Label("Mark Attendance", systemImage: "barcode.viewfinder")
                    }
                    .navigationTitle("Scan")
                ManageLessonsView()
                    .tabItem {
                        Label("Lessons", systemImage: "rectangle.inset.filled.and.person.filled")
                    }
                    .navigationTitle("Lessons")
                ManageStudentsView()
                    .tabItem {
                        Label("Students", systemImage: "person.fill")
                    }
                    .navigationTitle("Students")
            }
    }
}

