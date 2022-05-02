//
//  JSONStringBlocks.swift
//  
//
//  Created by Tyler Anger on 2022-04-23.
//

import Foundation

internal enum JSONStringBlocks {
    /// Create a string parser closure with the given character as the opening and closing of the string
    private static func stringParser(quote: Character) -> JSONBasicParsableBlock.ParseBlock {
        return { (_ string: UnsafePointer<String>,
                  _ startingAt: String.Index) -> JSONParsedResponse? in
            // make sure that the character at startingAt index is the quote character
            guard string.pointee[startingAt] == quote else { return nil }
            
            
            // Get index right after opening string quote
            var currentIndex = string.pointee.index(after: startingAt)
            var wasLastCharacterEscape: Bool = false
            while currentIndex < string.pointee.endIndex &&
                    string.pointee[currentIndex] != "\n" &&
                  (string.pointee[currentIndex] != quote ||
                   (string.pointee[currentIndex] == quote && wasLastCharacterEscape)) {
                
                wasLastCharacterEscape = string.pointee[currentIndex] == "\\"
                currentIndex = string.pointee.index(after: currentIndex)
            }
            guard currentIndex < string.pointee.endIndex else {
                return .openEndedBlock(prefix: "\(quote)",
                                       expectedSuffix: "\(quote)",
                                       startingAt: startingAt)
            }
            if string.pointee[currentIndex] == "\n" {
                return .openEndedBlock(prefix: "\(quote)",
                                       expectedSuffix: "\(quote)",
                                       startingAt: startingAt)
            }
            
            let outerRange = startingAt..<string.pointee.index(after: currentIndex)
            let innerRange = string.pointee.index(after: startingAt)..<currentIndex
            return .block(.init(outer: outerRange,
                                inner: innerRange))
        }
    }
    
    /// Static variable defining a Double Quoted String Parser Block
    public private(set) static var doubleQuoteStringBlock: JSONParsableBlock = {
        return JSONBasicParsableBlock(JSONStringBlocks.stringParser(quote: "\""))
    }()
}
