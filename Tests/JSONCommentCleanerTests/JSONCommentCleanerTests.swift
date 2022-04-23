import XCTest
@testable import JSONCommentCleaner

final class JSONCommentCleanerTests: XCTestCase {
    
    let jsonString: String = """
    {
        
        "testStringField": "String",
        
        "testIntField": 1,
        "testBoolField": true,
        "testArrayField": ["String 1", "String2", "String3"],
        "testComplex": {
            "testStringWithDoubleSlash": "String // with double slash",
            "testStringWithHash": "String # with hash",
            "testStringWithInline": "String /* ... */ with inline"
        }
    }
    """
    
    let jsonStringWithComments: String = """
    {
        //Field Comment 1
        "testStringField": "String",
        #Field Comment 2
        "testIntField": 1,
        "testBoolField": true,/*Field Comment 3*/
        "testArrayField": ["String 1", "String2", "String3"],
        "testComplex": {
            "testStringWithDoubleSlash": "String // with double slash",
            "testStringWithHash": "String # with hash",
            "testStringWithInline": "String /* ... */ with inline"
        }
    }
    """
    
    let jsonStringWithRecursiveInline: String = """
    {
        //Field Comment 1
        "testStringField": "String",
        #Field Comment 2
        "testIntField": 1,
        "testBoolField": true,/* Field Comment 3 */
        "testArrayField": ["String 1", "String2", "String3"],
        "testComplex": {/* Field /* comment */ 4 */
            "testStringWithDoubleSlash": "String // with double slash",
            "testStringWithHash": "String # with hash",
            "testStringWithInline": "String /* ... */ with inline"
        }
    }
    """
    
    let jsonStringWithDanglingStringField: String = """
    {
        //Field Comment 1
        "testStringField": "String",
        #Field Comment 2
        "testIntField": 1,
        "testBoolField": true,/* Field Comment 3 */
        "testArrayField": ["String 1", "String2", "String3"],
        "testComplex": {/* Field /* comment */ 4 */
            "testStringWithDoubleSlash": "String // with double slash",
            "testStringWithHash": "String # with hash",
            "testStringWithInline": "String /* ... */ with inline"
            "dangledString": "String...
        }
    }
    """
    
    let jsonStringWithDanglingInline1: String = """
    {
        //Field Comment 1
        "testStringField": "String",
        #Field Comment 2
        "testIntField": 1,
        "testBoolField": true,/* Field Comment 3 */
        "testArrayField": ["String 1", "String2", "String3"],
        "testComplex": {/* Field /* comment */ 4 */
            "testStringWithDoubleSlash": "String // with double slash",
            "testStringWithHash": "String # with hash",
            "testStringWithInline": "String /* ... */ with inline"
            "dangledInline": "String" /* dangled inline comment
        }
    }
    """
    
    let jsonStringWithDanglingInline2: String = """
    {
        //Field Comment 1
        "testStringField": "String",
        #Field Comment 2
        "testIntField": 1,
        "testBoolField": true,/* Field Comment 3 */
        "testArrayField": ["String 1", "String2", "String3"],
        "testComplex": {/* Field /* comment */ 4 */
            "testStringWithDoubleSlash": "String // with double slash",
            "testStringWithHash": "String # with hash",
            "testStringWithInline": "String /* ... */ with inline"
            "dangledInline": "String" /* dangled /*inline comment */
        }
    }
    """
    
    func testParsingComments() {
        let commentCleaner = JSONDefultCommentCleaner()
        do {
            let parsed = try commentCleaner.parse(self.jsonStringWithComments)
            XCTAssertEqual(parsed, jsonString)
            
            do { _ = try JSONSerialization.jsonObject(with: parsed.data(using: .utf8)!) }
            catch {
                XCTFail("Failed to parse json string jsonStringWithComments: \(error)")
            }
            
        } catch {
            XCTFail("Failed to parse jsonStringWithComments: \(error)")
        }
        do {
            let parsed2 = try commentCleaner.parse(self.jsonStringWithRecursiveInline)
            XCTAssertEqual(parsed2, jsonString)
            
            do { _ = try JSONSerialization.jsonObject(with: parsed2.data(using: .utf8)!) }
            catch {
                XCTFail("Failed to parse json string jsonStringWithRecursiveInline: \(error)")
            }
            
        } catch {
            XCTFail("Failed to parse jsonStringWithRecursiveInline: \(error)")
        }
    }
    
    func testDangling() {
        let commentCleaner = JSONDefultCommentCleaner()
        XCTAssertThrowsError(try commentCleaner.parse(self.jsonStringWithDanglingStringField)) {
            guard let e = $0 as? JSONDefultCommentCleaner.ParsingError else {
                XCTFail("Unexpected error of type '\(type(of: $0))' - \($0)")
                return
            }
            guard case .danglingString(_) = e else {
                XCTFail("Unexpected error value '\(e)'")
                return
            }
        }
        XCTAssertThrowsError(try commentCleaner.parse(self.jsonStringWithDanglingInline1)) {
            guard let e = $0 as? JSONDefultCommentCleaner.ParsingError else {
                XCTFail("Unexpected error of type '\(type(of: $0))' - \($0)")
                return
            }
            guard case .danglingInlineComment(index: _, openingBlock: _, expectedClosingBlock: _) = e else {
                XCTFail("Unexpected error value '\(e)'")
                return
            }
        }
        XCTAssertThrowsError(try commentCleaner.parse(self.jsonStringWithDanglingInline2)) {
            guard let e = $0 as? JSONDefultCommentCleaner.ParsingError else {
                XCTFail("Unexpected error of type '\(type(of: $0))' - \($0)")
                return
            }
            guard case .danglingInlineComment(index: _, openingBlock: _, expectedClosingBlock: _) = e else {
                XCTFail("Unexpected error value '\(e)'")
                return
            }
        }
        
    }

    static var allTests = [
        ("testParsingComments", testParsingComments),
        ("testDangling", testDangling)
    ]
}
