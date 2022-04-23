//
//  JSONCommentCleaner.swift
//  JSONCommentCleaner
//
//  Created by Tyler Anger on 2050-12-12.
//

import Foundation

/// Class used to parse comment blocks out of JSON
public class JSONCommentCleaner {
    
    public enum ParsingError: Swift.Error {
        case unableToDecodeString(from: Data,
                                  usingEncoding: String.Encoding)
        case unableToConvert(string: String,
                             toEncoding: String.Encoding)
        
        case unterminatedComment(blockOpening: String,
                                 blockClosing: String,
                                 atIndex: String.Index,
                                 line: Int,
                                 column: Int)
        
        case unterminatedString(stringIndicator: String,
                                atIndex: String.Index,
                                line: Int,
                                column: Int)
    }
    
    
    /// Optional settings when removing comment blocks
    public struct RemoveCommentOptions: OptionSet, ExpressibleByIntegerLiteral {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        public init(integerLiteral value: Int) { self.rawValue = value }
        
        public static let none: RemoveCommentOptions = 0
        public static let removeEmptyLines = RemoveCommentOptions(rawValue: 1 << 0)
    }
    
    /// An array of identifiable comment block types
    private let commentBlocks: [JSONParsableCommentBlock]
    
    private let options: RemoveCommentOptions
    
    /// Create new JSON Comment Cleaner
    /// - Parameters:
    ///   - commentBlocks: An array of identifiable comment block types
    ///   - options: Options when removing comments
    public init(commentBlocks: [JSONParsableCommentBlock],
                options: RemoveCommentOptions = .none) {
    
        self.commentBlocks = commentBlocks
        self.options = options
        
    }
    
    
    /// Parse the give JSON string and remove any comments before
    /// returning it
    ///
    /// - Parameter jsonString: The JSON Strign containing comments
    /// - Returns: The clean JSON string
    public func parse(_ jsonString: String) throws -> String {
        let stringBlock = JSONStringBlocks.doubleQuoteStringBlock
        
        var currentLine: Int = 1
        var workingString = jsonString
        var lastNewLineIndex: String.Index = workingString.startIndex
       
        var currentIndex = workingString.startIndex
        
        
        while currentIndex < workingString.endIndex {
            if workingString[currentIndex] == "\n" {
                currentLine += 1
                lastNewLineIndex = currentIndex
                // Move to next index
                currentIndex = workingString.index(after: currentIndex)
            } else if let pb = stringBlock.parse(string: &workingString,
                                                 startingAt: currentIndex) {
                switch pb {
                    case .block(let b):
                        // Move past the end of the string
                        currentIndex = b.outer.upperBound
                    case .openEndedBlock(prefix: let prefix,
                                         expectedSuffix: _,
                                         startingAt: let startBlockIndex):
                        if startBlockIndex > currentIndex {
                            // Sine the startBlockIndex if after the current index
                            // we need to check for any extra new line characters between
                            // currentIndex and startBlockIndex
                            currentLine += workingString.countOccurrences(of: "\n",
                                                                          inRange: currentIndex..<startBlockIndex)
                            
                            
                        }
                    
                        var column = 0
                        if let r = workingString.range(of: "\n",
                                                       options: .backwards,
                                                       range: lastNewLineIndex..<startBlockIndex) {
                            column = workingString.distance(from: r.upperBound,
                                                            to: startBlockIndex)
                        }
                        throw ParsingError.unterminatedString(stringIndicator: prefix,
                                                              atIndex: startBlockIndex,
                                                              line: currentLine,
                                                              column: column + 1)
                }
                
            } else if let cb = self.commentBlocks.firstResponse(from: { return $0.parse(string: &workingString,
                                                                            startingAt: currentIndex) }) {
                
                switch cb {
                    case .block(let b):
                        // Find how man new lines there are in the comment block
                        let subLines = workingString.countOccurrences(of: "\n",
                                                                      inRange: b.outer)
                        // Add the number of extra lines to the currentLine count
                        currentLine += subLines
                        // Remove the comment block from the string
                        workingString.removeSubrange(b.outer)
                    case .openEndedBlock(prefix: let prefix,
                                         expectedSuffix: let suffix,
                                         startingAt: let startBlockIndex):
                        if startBlockIndex > currentIndex {
                            // Sine the startBlockIndex if after the current index
                            // we need to check for any extra new line characters between
                            // currentIndex and startBlockIndex
                            currentLine += workingString.countOccurrences(of: "\n",
                                                                          inRange: currentIndex..<startBlockIndex)
                        }
                    
                        var column = 0
                        if let r = workingString.range(of: "\n",
                                                       options: .backwards,
                                                       range: lastNewLineIndex..<startBlockIndex) {
                            column = workingString.distance(from: r.upperBound,
                                                            to: startBlockIndex)
                        }
                        throw ParsingError.unterminatedComment(blockOpening: prefix,
                                                               blockClosing: suffix,
                                                               atIndex: startBlockIndex,
                                                               line: currentLine,
                                                               column: column + 1)
                }
                
            } else {
                // Move to next index
                currentIndex = workingString.index(after: currentIndex)
            }
            
        }
        
        if !self.options.isEmpty {
            var lines = workingString.split(separator: "\n").map(String.init)
            var index = lines.startIndex
            while index < lines.endIndex {
                if self.options.contains(.removeEmptyLines) &&
                    lines[index].rtrim().isEmpty {
                    lines.remove(at: index)
                } else {
                    index = lines.index(after: index)
                }
            }
            workingString = lines.joined(separator: "\n")
        }
        
        
        return workingString
    }
    
    
}

extension JSONCommentCleaner.ParsingError: CustomStringConvertible {
    
    public var description: String {
        switch self {
            case .unableToDecodeString(from: _,
                                       usingEncoding: let enc):
                return "Unable to decode string with '\(enc))'"
            case .unableToConvert(string: _,
                                  toEncoding: let enc):
                return "Unable to encode string with '\(enc))'"
            case .unterminatedComment(blockOpening: let prefix,
                                        blockClosing: let suffix,
                                        atIndex: _,
                                        line: let line,
                                        column: let column):
                var msg = "Error: Unterminated Comment '\(prefix)', on line: \(line), column: \(column) missing closing block"
                if suffix == "\n" || suffix == "\r\n" {
                    msg += " newLine"
                } else {
                    msg += " '\(suffix)'"
                }
                return msg
            case .unterminatedString(stringIndicator: let quote,
                                       atIndex: _,
                                       line: let line,
                                       column: let column):
                return "Error: Unterminated String '\(quote)', on line: \(line), column: \(column)"
        }
    }
}

extension JSONCommentCleaner {
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
}

/// Class used to parse comment blocks of a certain type out of JSON
public class JSONCommentSetCleaner<CommentType>: JSONCommentCleaner where CommentType: JSONBasicCommentBlock, CommentType: Hashable {
    
    /// Create new JSON Comment Cleaner
    /// - Parameters:
    ///   - commentBlocks: A set of identifiable comment block types
    ///   - options: Options when removing comments
    public init(commentBlocks: Set<CommentType>,
                options: RemoveCommentOptions = .none) {
        
        for comment in commentBlocks {
            precondition(!comment.openingBlock.isEmpty, "Opening block can not be empty")
            precondition(!comment.openingBlock.hasPrefix("\""), "Comment blocks can not start with '\"'")
        }
       super.init(commentBlocks: commentBlocks.map({ return $0 }),
                  options: options)
    }
}

#if swift(>=4.2)
public extension JSONCommentSetCleaner where CommentType: CaseIterable {
    convenience init(options: RemoveCommentOptions = .none) {
        self.init(commentBlocks: Set<CommentType>(CommentType.allCases),
                  options: options)
    }
}
#endif

public typealias JSONDefultCommentCleaner = JSONCommentSetCleaner<JSONDefaultCleanerComments>

//#if !swift(>=4.2)
public extension JSONCommentSetCleaner where CommentType == JSONDefaultCleanerComments {
    convenience init(options: RemoveCommentOptions = .none) {
        self.init(commentBlocks: [.doubleSlash, .hash, .inline],
                  options: options)
    }
}
//#endif
