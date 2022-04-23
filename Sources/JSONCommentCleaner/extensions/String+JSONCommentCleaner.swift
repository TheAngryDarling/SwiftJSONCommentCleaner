//
//  String+JSONCommentCleaner.swift
//  JSONCommentCleaner
//
//  Created by Tyler Anger on 2020-12-14.
//

import Foundation

internal extension String {
    func getSubString(from index: String.Index, withMaxLength length: Int) -> String? {
        guard index < self.endIndex else { return nil }
        var index = index
        var count: Int = 0
        var rtn: String = ""
        while index < self.endIndex && count < length {
            rtn += String(self[index])
            index = self.index(after: index)
            count += 1
        }
        
        return rtn
    }
    
    /// Counts a the number of times a string occurs
    func countOccurrences<Target>(of string: Target, inRange searchRange: Range<String.Index>? = nil) -> Int where Target : StringProtocol {
        var rtn: Int = 0
        var workingRange: Range<String.Index>? = searchRange ?? Range<String.Index>(uncheckedBounds: (lower: self.startIndex,
                                                                                                      upper: self.endIndex))
        while workingRange != nil {
            guard let r = self.range(of: string, range: workingRange) else {
                break
            }
            rtn += 1
            if r.upperBound == workingRange!.upperBound { workingRange = nil }
            else {
                workingRange = Range<String.Index>(uncheckedBounds: (lower: r.upperBound,
                                                                     upper: workingRange!.upperBound))
            }
        }
        
        return rtn
    }
    
    /// Counts a the number of times a string occurs
    func countOccurrences<Target>(of string: Target, before: String.Index) -> Int where Target : StringProtocol {
        return self.countOccurrences(of: string, inRange: self.startIndex..<before)
    }
    
    /// Trims any spaces from the right side of the given string
    func rtrim() -> String {
        var rtn: String = self
        while rtn.hasSuffix(" ") { rtn.removeLast() }
        return rtn
    }
    
    /// Trims any spaces from the left side of the given string
    func ltrim() -> String {
        var rtn: String = self
        while rtn.hasPrefix(" ") { rtn.removeFirst() }
        return rtn
    }
    
    /// Trims any spaces from both sides of the given string
    func trim() -> String {
        var rtn: String = self
        while rtn.hasPrefix(" ") { rtn.removeFirst() }
        while rtn.hasSuffix(" ") { rtn.removeLast() }
        return rtn
    }
    
    func range<T>(of aString: T,
                  options mask: String.CompareOptions = [],
                  startingAt startIndex: String.Index,
                  endingBefore endIndex: String.Index? = nil,
                  locale: Locale? = nil) -> Range<String.Index>? where T : StringProtocol {
        return self.range(of: aString,
                          options: mask,
                          range: startIndex..<(endIndex ?? self.endIndex),
                          locale: locale)
    }
}
