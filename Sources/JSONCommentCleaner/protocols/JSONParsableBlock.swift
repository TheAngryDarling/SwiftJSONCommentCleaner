//
//  File.swift
//  
//
//  Created by Tyler Anger on 2022-04-23.
//

import Foundation

public protocol JSONParsableBlock {
    /// Parse the given string for the block
    /// - Parameters:
    ///   - string: The string to parse
    ///   - startingAt: Where to start looking for block
    /// - Returns: Returns the parsed response. Whether a block was found and parsed, found but unable to parse, or nil if not found
    func parse(string: UnsafePointer<String>,
               startingAt: String.Index) -> JSONParsedResponse?
}

public struct JSONBasicParsableBlock: JSONParsableBlock {
    /// Parse the given string for the block
    /// - Parameters:
    ///   - string: The string to parse
    ///   - startingAt: Where to start looking for block
    /// - Returns: Returns the parsed response. Whether a block was found and parsed, found but unable to parse, or nil if not found
    public typealias ParseBlock = (_ string: UnsafePointer<String>,
                                   _ startingAt: String.Index) -> JSONParsedResponse?
    
    /// The parser method to call
    private let _parser: ParseBlock
    /// Create a new parsable block
    public init(_ parser: @escaping ParseBlock) {
        self._parser = parser
    }
    
    public func parse(string: UnsafePointer<String>,
                      startingAt: String.Index) -> JSONParsedResponse? {
        return self._parser(string, startingAt)
    }
}
