//
//  TextFile.swift
//  CHEN
//
//  Created by Sean on 24/3/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// Generic text export FileDocument thank you Paul Hudson
struct TextFile: FileDocument {
    static var readableContentTypes: [UTType] = [.plainText]
    
    var text: String = ""
    
    init(text initialText: String = "") {
        text = initialText
    }
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
    
    
}
