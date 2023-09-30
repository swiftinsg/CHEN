//
//  ScanView.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import SwiftUI
import SwiftNFC
import CoreNFC

struct ScanView: View {
    @ObservedObject var reader = NFCReader()
    var body: some View {
        VStack {
            Text(reader.msg)
            Button {
                    reader.read()
            } label: {
                Text("Click here to scan")
            }
        }
        .onAppear {
            reader.msg = "Nothing scanned yet"
            reader.startAlert = "Scanning..."
        }
        .onChange(of: reader.msg) { newValue in
            if newValue == "Nothing scanned yet" { return }
            
            print("Card read: \(newValue)")
        }
        
    }
    

}
