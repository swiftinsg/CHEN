//
//  TextFile.swift
//  CHEN
//
//  Created by Sean on 24/3/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct TextExport: Transferable {

    var text: String
    
    // Might not be used. maybe introduce enum for export types in the future?
    var lessonLabel: String?
    func generateExport() -> Data {
        return Data(text.utf8)
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) { (text: TextExport) in
            return text.generateExport()
        }
        .suggestedFileName { text in
            if let label = text.lessonLabel {
                "\(label) attendances.txt"
            } else {
                "attendances.txt"
            }
        }
    }
}
