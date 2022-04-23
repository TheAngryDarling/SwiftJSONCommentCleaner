//
//  UnsafePointer+JSONCommentCleaner.swift
//  
//
//  Created by Tyler Anger on 2022-04-23.
//

import Foundation

internal extension UnsafePointer where Pointee == String {
    var startIndex: String.Index { return self.pointee.startIndex }
    var endIndex: String.Index { return self.pointee.endIndex }
    /// Returns the position immediately after the given index.
    func index(after i: String.Index) -> String.Index {
        return self.pointee.index(after: i)
    }
    /// Returns the position immediately before the given index.
    func index(before i: String.Index) -> String.Index {
        return self.pointee.index(before: i)
    }
    #if swift(>=4.1)
    /// Returns an index that is the specified distance from the given index.
    func index(_ i: String.Index,
               offsetBy n: Int) -> String.Index {
        return self.pointee.index(i, offsetBy: n)
    }
    
    /// Returns an index that is the specified distance from the given index, unless that distance is beyond a given limiting index.
    func index(_ i: String.Index,
               offsetBy n: Int,
               limitedBy limit: String.Index) -> String.Index? {
        return self.pointee.index(i,
                                  offsetBy: n,
                                  limitedBy: limit)
    }
    #else
    /// Returns an index that is the specified distance from the given index.
    func index(_ i: String.Index,
               offsetBy n: String.IndexDistance) -> String.Index {
        return self.pointee.index(i, offsetBy: n)
    }
    
    /// Returns an index that is the specified distance from the given index, unless that distance is beyond a given limiting index.
    func index(_ i: String.Index,
               offsetBy n: String.IndexDistance,
               limitedBy limit: String.Index) -> String.Index? {
        return self.pointee.index(i,
                                  offsetBy: n,
                                  limitedBy: limit)
    }
    #endif
    /// Accesses a contiguous subrange of the collection’s elements.
    subscript(r: Range<String.Index>) -> Substring {
        return self.pointee[r]
    }
    
    /// Accesses the contiguous subrange of the collection’s elements specified by a range expression.
    subscript<R>(r: R) -> Substring where R : RangeExpression, String.Index == R.Bound {
        return self.pointee[r]
    }
    
    func range<T>(of aString: T,
                  options mask: String.CompareOptions = [],
                  startingAt startIndex: String.Index,
                  endingBefore endIndex: String.Index? = nil,
                  locale: Locale? = nil) -> Range<String.Index>? where T : StringProtocol {
        return self.pointee.range(of: aString,
                                  options: mask,
                                  startingAt: startIndex,
                                  endingBefore: endIndex,
                                  locale: locale)
    }
}
