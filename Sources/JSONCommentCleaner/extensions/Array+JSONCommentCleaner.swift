//
//  Array+JSONCommentCleaner.swift
//  JSONCommentCleaner
//
//  Created by Tyler Anger on 2020-12-14.
//

import Foundation

internal extension Array {
    /// Finds the first element that returns a result from the predicate
    /// - Parameter predicate: The closure to call passing each element
    /// - Returns: Returns a valid response from predicate or nil if no element produces a response from predicate
    func firstResponse<R>(from predicate: (Element) throws -> R?) rethrows -> R? {
        for e in self {
            if let r = try predicate(e) {
                return r
            }
        }
        return nil
    }
}
