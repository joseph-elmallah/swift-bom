//
//  Swift-BOM
//
//  MIT License
//
//  Copyright (c) 2021-Present Joseph El Mallah
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import XCTest
import BOM

final class BOMTests: XCTestCase {
    
    private var testDataURL: URL {
        Bundle.module.resourceURL!.appendingPathComponent("TestData", isDirectory: true)
    }
    
    private func getTestFileURL(name: String) -> URL {
        testDataURL.appendingPathComponent(name).appendingPathExtension("txt")
    }
    
    private func getDataBOM(fileName: String) throws -> BOM? {
        let testFile = getTestFileURL(name: fileName)
        let data = try Data(contentsOf: testFile)
        return BOM(data: data)
    }
    
    func testDataNoBOM() throws {
        let bom = try getDataBOM(fileName: "no_bom")
        XCTAssertNil(bom)
    }
    
    func testDataUTF8() throws {
        let bom = try getDataBOM(fileName: "utf8_bom")
        XCTAssertNotNil(bom)
        XCTAssertEqual(bom?.encoding, .utf8)
    }
    
    func testDataUTF16BigEndian() throws {
        let bom = try getDataBOM(fileName: "utf16be_bom")
        XCTAssertNotNil(bom)
        XCTAssertEqual(bom?.encoding, .utf16BigEndian)
    }
    
    func testDataUTF16LittleEndian() throws {
        let bom = try getDataBOM(fileName: "utf16le_bom")
        XCTAssertNotNil(bom)
        XCTAssertEqual(bom?.encoding, .utf16LittleEndian)
    }
    
    func testDataUTF32BigEndian() throws {
        let bom = try getDataBOM(fileName: "utf32be_bom")
        XCTAssertNotNil(bom)
        XCTAssertEqual(bom?.encoding, .utf32BigEndian)
    }
    
    func testDataUTF32LittleEndian() throws {
        let bom = try getDataBOM(fileName: "utf32le_bom")
        XCTAssertNotNil(bom)
        XCTAssertEqual(bom?.encoding, .utf32LittleEndian)
    }
    
    func testStreamNoBOM() throws {
        let bom = try BOM(fileURL: getTestFileURL(name: "no_bom"))
        XCTAssertNil(bom)
    }
    
    func testStreamUTF8() throws {
        let bom = try BOM(fileURL: getTestFileURL(name: "utf8_bom"))
        XCTAssertNotNil(bom)
        XCTAssertEqual(bom?.encoding, .utf8)
    }
    
    func testUnsupportedURL() {
        do {
            _ = try BOM(fileURL: URL(string: "https://me.josephmallah.com")!)
            XCTFail("Expected an error to be thrown")
        } catch BOMError.notSupportedURL {
            // Success
        } catch {
            XCTFail("Thrown error is incorrect")
        }
    }
    
    func testFileNotFound() {
        do {
            _ = try BOM(fileURL: getTestFileURL(name: "not_existing_file"))
            XCTFail("Expected an error to be thrown")
        } catch BOMError.inputStreamFailed {
            // Success
        } catch {
            XCTFail("Thrown error is incorrect")
        }
    }
}
