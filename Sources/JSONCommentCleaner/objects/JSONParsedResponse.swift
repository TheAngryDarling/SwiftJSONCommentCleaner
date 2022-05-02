//
//  File.swift
//  
//
//  Created by Tyler Anger on 2022-04-23.
//

import Foundation

/// Resposne to a parsed block
public enum JSONParsedResponse {
    
    /// The parsed block details
    public struct BlockDetails {
        let outer: Range<String.Index>
        let inner: Range<String.Index>
    }
    /// Could not pasrse block, could not find block closure
    case openEndedBlock(prefix: String,
                        expectedSuffix: String,
                        startingAt: String.Index)
    /// A parsed block
    case block(BlockDetails)
}
