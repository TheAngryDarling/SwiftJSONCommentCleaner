//
//  JSONCommentCleaner.swift
//  JSONCommentCleaner
//
//  Created by Tyler Anger on 2050-12-12.
//

import Foundation

/// Class used to parse comment blocks out of JSON
public class JSONCommentCleaner {
    /// An array of identifiable comment block types
    private let supportedCommentTypes: [JSONCleanerComment]
    
    /// Create new JSON Comment Cleaner
    /// - Parameter supportedCommentTypes: An array of identifiable comment block types
    public init(supportedCommentTypes: [JSONCleanerComment]) {
        
        for comment in supportedCommentTypes {
            precondition(!comment.openingBlock.isEmpty, "Opening block can not be empty")
            precondition(!comment.openingBlock.hasPrefix("\""), "Comment blocks can not start with '\"'")
        }
        self.supportedCommentTypes = supportedCommentTypes
        
    }
    
    public enum ParsingError: Swift.Error {
        case unableToDecodeString(from: Data, usingEncoding: String.Encoding)
        case unableToConvert(string: String, toEncoding: String.Encoding)
        case danglingString(String.Index)
        case danglingInlineComment(index: String.Index, openingBlock: String, expectedClosingBlock: String)
    }
    
    /// Parse the JSON Data object and return as a clean JSON string
    /// - Parameters:
    ///   - jsonData: The data representing the JSON with comments
    ///   - encoding: The encoding of the data
    /// - Returns: The clean JSON string
    public func parseToString(_ jsonData: Data, encoding: String.Encoding) throws -> String {
        guard let string = String(data: jsonData, encoding: encoding) else {
            throw ParsingError.unableToDecodeString(from: jsonData, usingEncoding: encoding)
        }
        return try parse(string)
    }
    /// Parse the JSON data object and return as clean JSON data
    /// - Parameters:
    ///   - jsonData: The data representing the JSON with comments
    ///   - encoding: The encoding of the data
    /// - Returns: The clean JSON data
    public func parse(_ jsonData: Data, encoding: String.Encoding) throws -> Data {
        let string = try parseToString(jsonData, encoding: encoding)
        guard let dta = string.data(using: encoding) else {
            throw ParsingError.unableToConvert(string: string, toEncoding: encoding)
        }
        return dta
    }
    
    /// Parse the give JSON data and return it in String form
    ///
    /// Returns the clean JSON string
    /// - Parameters:
    ///   - jsonURL: The url to the JSON content
    ///   - encoding: The encoding used to read the JSON content as a string
    /// - Returns: The clean JSON string
    public func parseToString(_ jsonURL: URL,
                              usedEncoding encoding: inout String.Encoding) throws -> String {
        let str = try String(contentsOf: jsonURL, usedEncoding: &encoding)
        return try self.parse(str)
    }
    /// Parse the give JSON data and return it in String form
    ///
    /// Returns the JSON string with the comments removed
    /// Throws ParsingError if there were problems paring the string
    public func parseToString(_ jsonURL: URL) throws -> String {
        var encoding: String.Encoding = .utf8
        return try parseToString(jsonURL, usedEncoding: &encoding)
    }
    
    /// Parse the give JSON data and return it in Data form
    /// - Parameters:
    ///   - jsonURL: The url to the JSON content
    ///   - encoding: The encoding used to read the JSON content as a string
    /// - Returns: The clean JSON data
    public func parse(_ jsonURL: URL,
                      usedEncoding encoding: inout String.Encoding) throws -> Data {
        //var encoding: String.Encoding = .utf8
        let string = try parseToString(jsonURL, usedEncoding: &encoding)
        guard let dta = string.data(using: encoding) else {
            throw ParsingError.unableToConvert(string: string, toEncoding: encoding)
        }
        return dta
    }
    
    
    /// Parse the give JSON data and return it in Data form
    /// - Parameter jsonURL: The url to the JSON content
    /// - Returns: The clean JSON data
    public func parse(_ jsonURL: URL) throws -> Data {
        var encoding: String.Encoding = .utf8
        return try self.parse(jsonURL, usedEncoding: &encoding)
    }
    
    /// Parse the give JSON string and remove any comments before
    /// returning it
    ///
    /// - Parameter jsonString: The JSON Strign containing comments
    /// - Returns: The clean JSON string
    public func parse(_ jsonString: String) throws -> String {
        var workingString = jsonString
        
        // Put functions within parse function so that the workingSting would
        // not need to be copied with every call do these functions
        
        /// Find the end of the string block we're currently in
        func endOfString(startingAt index: String.Index) -> String.Index? {
            var workingIndex = workingString.index(after: index)
            while workingIndex < workingString.endIndex {
                if workingString[workingIndex] == "\"" && // Find the " and make sure its not \"
                    workingString[workingString.index(before: workingIndex)] != "\\" {
                    //print("Found String '\(String(workingString[index...workingIndex]))'")
                    return workingIndex
                }
                workingIndex = workingString.index(after: workingIndex)
            }
            return nil
        }
        /// Find the end of the current line
        func processToEndOfLine(startingAt index: String.Index) -> String.Index {
            var workingIndex = workingString.index(after: index)
            while workingIndex < workingString.endIndex {
                if workingString[workingIndex] == "\n" { // Find the end of the line
                    if workingIndex > workingString.startIndex &&
                        workingString[workingString.index(before: workingIndex)] == "\r" {
                        return workingString.index(before: workingIndex)
                    }
                    return workingIndex
                }
                workingIndex = workingString.index(after: workingIndex)
            }
            return workingIndex
        }
        /// Process an inline comment block (A comment block that start and finishes
        /// on the same line and can have real data on either side of it
        func processInlineComment(startingAt index: String.Index,
                                  withOpening opening: String,
                                  havingClosing closing: String,
                                  allowsRecursive: Bool) -> String.Index? {
            
            
            guard var workingIndex = workingString.index(index, offsetBy: opening.count, limitedBy: workingString.endIndex) else { return nil }
            while workingIndex < workingString.endIndex {
                if allowsRecursive,
                   let subBlock = workingString.getSubString(from: workingIndex, withMaxLength: opening.count),
                   subBlock == opening {
                    guard let idx = processInlineComment(startingAt: workingIndex,
                                                         withOpening: opening,
                                                         havingClosing: closing,
                                                         allowsRecursive: allowsRecursive) else {
                        return nil
                    }
                    workingIndex = idx
                } else if let subBlock = workingString.getSubString(from: workingIndex, withMaxLength: closing.count),
                          subBlock == closing {
                    return workingString.index(workingIndex, offsetBy: closing.count)
                }
                
                workingIndex = workingString.index(after: workingIndex)
            }
            
            return nil
            
        }
        
        var workingIndex = workingString.startIndex
        // Loop through the characters of the string
        while workingIndex < workingString.endIndex {
            
            // check to see if we are at the opening of a string
            if workingString[workingIndex] == "\"" {
                // Find the end of the string
                guard let stringEndingAt = endOfString(startingAt: workingIndex) else {
                    throw ParsingError.danglingString(workingIndex)
                }
                // skip over the string
                workingIndex = stringEndingAt
            } else {
                // loop through the supported comment block types
                // to see if we are at the beginning of one of them
                for comment in self.supportedCommentTypes {
                    // Make sure that we are starting with the comment block
                    guard let checkedBlock = workingString.getSubString(from: workingIndex,
                                                                        withMaxLength: comment.openingBlock.count),
                          checkedBlock == comment.openingBlock else {
                        continue
                    }
                    // See of the current comment block type
                    // has a closing block sequence meaning
                    // its an inline block
                    if let closing = comment.closingBLock {
                        // Find the end of the inline comment block
                        guard let endOfComment = processInlineComment(startingAt: workingIndex,
                                                                      withOpening: comment.openingBlock,
                                                                      havingClosing: closing,
                                                                      allowsRecursive: comment.supportsRecuriveInline) else {
                            throw ParsingError.danglingInlineComment(index: workingIndex,
                                                                     openingBlock: comment.openingBlock,
                                                                     expectedClosingBlock: closing)
                        }
                        workingString.removeSubrange(workingIndex..<endOfComment)
                        
                    } else {
                        // Since no closing block then we process to the end of the line
                        let endOfLine = processToEndOfLine(startingAt: workingIndex)
                        workingString.removeSubrange(workingIndex..<endOfLine)
                    }
                    
                }
            }
            
            workingIndex = workingString.index(after: workingIndex)
        }
        
        
        return workingString
        
        
    }
    
    
}

/// Class used to parse comment blocks of a certain type out of JSON
public class JSONCommentSetCleaner<CommentType>: JSONCommentCleaner where CommentType: JSONCleanerComment, CommentType: Hashable {
    
    /// Create new JSON Comment Cleaner
    /// - Parameter supportedCommentTypes: A set of identifiable comment block types
    public init(supportedCommentTypes: Set<CommentType>) {
        
        var cts: [JSONCleanerComment] = []
        for item in supportedCommentTypes {
            cts.append(item)
        }
        super.init(supportedCommentTypes: supportedCommentTypes.map({ return $0 }))
    }
}

#if swift(>=4.2)
public extension JSONCommentSetCleaner where CommentType: CaseIterable {
    convenience init() {
        self.init(supportedCommentTypes: Set<CommentType>(CommentType.allCases))
    }
}
#endif

public typealias JSONDefultCommentCleaner = JSONCommentSetCleaner<DefaultJSONCleanerComments>

//#if !swift(>=4.2)
public extension JSONCommentSetCleaner where CommentType == DefaultJSONCleanerComments {
    convenience init() {
        self.init(supportedCommentTypes: [.doubleSlash, .hash, .inline])
    }
}
//#endif
