//
//  String+LocalisedError.swift
//  CHEN
//
//  Created by Sean on 9/10/24.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
