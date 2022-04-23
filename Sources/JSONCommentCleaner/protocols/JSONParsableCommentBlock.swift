//
//  JSONParsableCommentBlock.swift
//  
//
//  Created by Tyler Anger on 2022-04-23.
//

import Foundation

public protocol JSONParsableCommentBlock: JSONParsableBlock {
    /// If this comment has an ending block, this flag allows nested comment blocks ofthe same type.
    /// Meaning for every opening block there MUST be a closing block
    var allowNestedCommentBlocks: Bool { get }
    /// Indicator if ending new lines should be considered within the comment block or not
    var keepEndingNewLine: Bool { get }
}

public extension JSONParsableCommentBlock {
    var allowNestedCommentBlocks: Bool { return false }
    var keepEndingNewLine: Bool { return true }
}

public struct JSONBasicParsableCommentBlock: JSONParsableCommentBlock {
    public typealias ParseBlock = (_ string: UnsafePointer<String>,
                                   _ startingAt: String.Index) -> JSONParsedResponse?
    
    private let _parser: ParseBlock
    
    public var allowNestedCommentBlocks: Bool
    public var keepEndingNewLine: Bool
    /// Create a new parsable block
    /// - Parameters:
    ///   - allowNestedCommentBlocks: Allows for the comment to have nested comments of the same type
    ///   - keepEndingNewLine: Indicator if ending new lines should be considered within the comment block or not
    ///   - parser: The parser method
    public init(allowNestedCommentBlocks: Bool = false,
                keepEndingNewLine: Bool = false,
                _ parser: @escaping ParseBlock) {
        self.allowNestedCommentBlocks = allowNestedCommentBlocks
        self.keepEndingNewLine = keepEndingNewLine
        self._parser = parser
    }
    
    public func parse(string: UnsafePointer<String>,
                      startingAt: String.Index) -> JSONParsedResponse? {
        return self._parser(string, startingAt)
    }
}
