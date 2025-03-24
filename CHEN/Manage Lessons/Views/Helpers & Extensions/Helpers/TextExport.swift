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
    var lessonLabel: String
    func generateExport() -> Data {
        return Data(text.utf8)
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .data) { (text: TextExport) in
            return text.generateExport()
        }
        .suggestedFileName { text in
            "\(text.lessonLabel) attendances.txt"
        }
    }
}
