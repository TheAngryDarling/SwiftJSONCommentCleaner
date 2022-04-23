//
//  JSONCleanerComment.swift
//  
//
//  Created by Tyler Anger on 2022-04-23.
//

import Foundation

/// A Protocol used to define a comment block within JSON
public protocol JSONCleanerComment {
    /// The sequence of characters indicating the beginning of the comment
    var openingBlock: String { get }
    /// If this comment type is inline, meaning it doesn't go to the end of the line,
    /// then this is the sequence of characters indicating the end
    var closingBLock: String? { get }
    /// If this comment has an ending block, this flag allows nested comment blocks ofthe same type.
    /// Meaning for every opening block there MUST be a closing block
    var supportsRecuriveInline: Bool { get }
}
