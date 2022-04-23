//
//  JSONBasicCommentBlock.swift
//  
//
//  Created by Tyler Anger on 2022-04-23.
//

import Foundation

/// A Protocol used to define a comment block within JSON
public protocol JSONBasicCommentBlock: JSONParsableCommentBlock {
    /// The sequence of characters indicating the beginning of the comment
    var openingBlock: String { get }
    /// If this comment type is inline, meaning it doesn't go to the end of the line,
    /// then this is the sequence of characters indicating the end
    var closingBlock: String? { get }
}

public extension JSONBasicCommentBlock {
    func parse(string: UnsafePointer<String>,
               startingAt: String.Index) -> JSONParsedResponse? {
        let prefix = self.openingBlock
        let suffix = self.closingBlock ?? "\n"
        let endOfPrefixIndex = string.index(startingAt,
                                            offsetBy: prefix.count,
                                            limitedBy: string.pointee.endIndex)
        let prefixCheck = String(string[startingAt..<(endOfPrefixIndex ?? string.pointee.endIndex)])
        guard prefixCheck == prefix else {
            // Comment block prefix not found
            return nil
        }
        
        // Skip past the comment block prefix before searching for the suffix
        let indexAfterPrefix = string.index(startingAt, offsetBy: prefix.count)
        // Find the comment block suffix
        guard let endOfComment = string.range(of: suffix,
                                              startingAt: indexAfterPrefix) else {
            return .openEndedBlock(prefix: prefix,
                                   expectedSuffix: suffix,
                                   startingAt: startingAt)
        }
        
        var endingOuter = endOfComment.upperBound
        var endingInner = endOfComment.lowerBound
        
        if self.allowNestedCommentBlocks {
            
            var innerWorkingIndex = indexAfterPrefix
            var endOfSearchIndex = endOfComment.lowerBound
            // Loop throug all inner comment blocks
            while innerWorkingIndex < endOfSearchIndex {
                if let p = self.parse(string: string, startingAt: innerWorkingIndex) {
                    guard case .block(let b) = p else {
                        return p
                    }
                    //print(String(string.pointee[b.outer]))
                    if b.outer.upperBound >= endOfSearchIndex {
                        guard let eoc2 = string.range(of: suffix,
                                                      startingAt: b.outer.upperBound) else {
                            return .openEndedBlock(prefix: prefix,
                                                   expectedSuffix: suffix,
                                                   startingAt: startingAt)
                        }
                        
                        endOfSearchIndex = eoc2.lowerBound
                    }
                    innerWorkingIndex = b.outer.upperBound
                } else {
                    innerWorkingIndex = string.index(after: innerWorkingIndex)
                }
            }
            
            guard let end = string.range(of: suffix,
                                         startingAt: innerWorkingIndex) else {
                return .openEndedBlock(prefix: prefix,
                                       expectedSuffix: suffix,
                                       startingAt: startingAt)
            }
            
            endingOuter = end.upperBound
            endingInner = end.lowerBound
            
        }
        if self.keepEndingNewLine &&
            suffix.hasSuffix("\n") &&
            string.pointee[string.pointee.index(before: endingOuter)] == "\n" {
            
            // set new ending index before the \n
            var newEndingIndex = string.pointee.index(before: endingOuter)
            // See if the new previous index is a \r (Windows new lines is \r\n)
            if string.pointee[string.pointee.index(before: newEndingIndex)] == "\r" {
                // Move the new ending to before the \r
                newEndingIndex = string.pointee.index(before: newEndingIndex)
            }
            endingOuter = newEndingIndex
            endingInner = newEndingIndex
        }
        // Return the new details
        return .block(.init(outer:startingAt..<endingOuter,
                            inner: indexAfterPrefix..<endingInner))
        
    }
}
