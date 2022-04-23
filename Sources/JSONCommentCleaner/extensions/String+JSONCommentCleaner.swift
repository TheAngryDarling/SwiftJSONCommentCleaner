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
}
