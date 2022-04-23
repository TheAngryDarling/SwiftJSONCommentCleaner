//
//  DefaultJSONCleanerComments.swift
//  
//
//  Created by Tyler Anger on 2022-04-23.
//

import Foundation

/// An enum defining common JSON Comment Blocks
public enum DefaultJSONCleanerComments: String, JSONCleanerComment {
    /// Support comment line starting with //
    case doubleSlash
    /// Support comment line starting with #
    case hash
    /// Support inline comment /*...*/
    /// This will stop after it finds the first close (*/)
    case inline
    
    
    public var openingBlock: String {
        switch self {
            case .doubleSlash: return "//"
            case .hash: return "#"
            case .inline: return "/*"
        }
    }
    
    public var closingBLock: String? {
        switch self {
            case .inline: return "*/"
            default: return nil
        }
    }
    
    public var supportsRecuriveInline: Bool {
        switch self {
            case .inline: return true
            default: return false
        }
    }
    
}

#if swift(>=4.2)
extension DefaultJSONCleanerComments: CaseIterable { }
#endif
