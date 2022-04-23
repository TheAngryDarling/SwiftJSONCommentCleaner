//
//  File.swift
//  
//
//  Created by Tyler Anger on 2022-04-23.
//

import Foundation

public protocol JSONParsableBlock {
    func parse(string: UnsafePointer<String>,
               startingAt: String.Index) -> JSONParsedResponse?
}

public struct JSONBasicParsableBlock: JSONParsableBlock {
    public typealias ParseBlock = (_ string: UnsafePointer<String>,
                                   _ startingAt: String.Index) -> JSONParsedResponse?
    
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
