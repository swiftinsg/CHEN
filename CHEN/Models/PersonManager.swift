//
//  DataManager.swift
//  CHEN
//
//  Created by Sean Wong on 19/8/23.
//

import Foundation

import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var items: [<#Type#>] = [] {
        didSet {
            save()
        }
    }
        
    init() {
        load()
    }
    
    func getArchiveURL() -> URL {
        let plistName = "<#item#>s.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    func save() {
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        let encoded<#Type#>s = try? propertyListEncoder.encode(<#item#>s)
        try? encoded<#Type#>s?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
                
        if let retrieved<#Type#>Data = try? Data(contentsOf: archiveURL),
            let <#item#>sDecoded = try? propertyListDecoder.decode([<#Type#>].self, from: retrieved<#Type#>Data) {
            <#item#>s = <#item#>sDecoded
        }
    }
}
