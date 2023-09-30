//
//  ContentView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }
            ManageView()
                .tabItem {
                    Label("Manage", systemImage: "gear")
                }
            GenerateView()
                .tabItem {
                    Label("Generate", systemImage: "pencil.line")
                }
        }
    }
}

