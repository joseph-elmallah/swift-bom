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

import Foundation
import ErrorFramework

/// Byte ordered mark (BOM)
///
/// A struct capable of parsing and returning the encoding of a `Data` or a `File` if available.
///
/// The byte order mark (BOM) is a particular usage of the special Unicode character, U+FEFF BYTE ORDER MARK, whose appearance as a magic number at the start of a text stream can signal several things to a program reading the text:
/// 1. The byte order, or endianness, of the text stream in the cases of 16-bit and 32-bit encodings
/// 2. The fact that the text stream's encoding is Unicode, to a high level of confidence
/// 3. Which Unicode character encoding is used
///
/// - Note: More information can be found on [Wikipedia: Byte order mark](https://en.wikipedia.org/wiki/Byte_order_mark)
public struct BOM: ErrorDomain {
    
    // MARK: - Error
    public typealias FailureType = BOMError
    
    /// Errors thrown from the BOM
    public enum BOMError: Int, ErrorDomainFailure {
        /// Errors related to the stream opened for a file
        case streamError = 0
    }
    
    public static var errorDomain: String { "BOM" }
    
    // MARK: - Properties
    
    /// The detected encoding
    public let encoding: String.Encoding
    
    // Length 4 wich correspond to the longest BOM sequence.
    public static let maxByteCountToDetectBOM: Int = 4
    
    // MARK: - Initialization
    
    /// Attempts to parse the BOM of a file.
    ///
    /// The file is not loaded in memory, but an `InputStream` is used to parse the first couple of bytes in order to determin the encoding lazily.
    /// Getting a `nil` value means that no `BOM` was detected.
    ///
    /// - Parameter fileURL: The URL of the file on disk
    /// - Throws: ``BOMError`` for unsupported `URLs` and `InputStream` errors generated when reading the file
    public init?(fileURL: URL) throws {
        // Create an input stream with the url.
        guard let inputStream = InputStream(url: fileURL) else {
            // The stream beign nil indicates that the passed URL is not supported.
            throw Error<BOM>(.streamError, underlyingError: nil, errorDescription: "Cannot create stream", failureReason: "The URL is not supported: \(fileURL)", helpAnchor: "Chose a URL pointing to a resource on disk.")
        }
        // Attempt to open the stream.
        inputStream.open()
        
        defer {
            // Make sure that the stream is closed after finishing the instansiation.
            inputStream.close()
        }
        
        // Check if there is an error with opening the stream
        if let error = inputStream.streamError {
            // Throw the error if found
            throw Error<BOM>(.streamError, underlyingError: error, errorDescription: "Opening the stream failed", failureReason: error.localizedDescription, helpAnchor: "Check the underlying error for more details")
        }
        
        // Prepare a buffer.
        var buffer = [UInt8](repeating: 0, count: Self.maxByteCountToDetectBOM)
        // Read the first 4 bytes
        let length = inputStream.read(&buffer, maxLength: buffer.count)
        if length == -1 {
            // An error occurred
            if let error = inputStream.streamError {
                // Throw the error if found
                throw Error<BOM>(.streamError, underlyingError: error, errorDescription: "Reading the stream failed", failureReason: error.localizedDescription, helpAnchor: "Check the underlying error for more details")
            } else {
                // If there is no error, just return nil
                return nil
            }
        }
        
        // We have enough bytes to make a prediction
        self.init(buffer: buffer)
    }
    
    /// Attempts to parse the BOM from a buffer struct.
    ///
    /// The first couple of bytes of the buffer will be analyzed to determin the encoding.
    /// Getting a `nil` value means that no `BOM` was detected.
    ///
    /// - Parameter data: The buffer to detect the encoding
    public init?(buffer: Array<UInt8>) {
        // Make sure we have enough bytes to predict the encoding
        guard buffer.count > 1 else {
            return nil
        }
        
        // We have enough bytes to make a prediction
        self.init(
            bom0: buffer[0],
            bom1: buffer[1],
            bom2: buffer.element(at: 2),
            bom3: buffer.element(at: 3)
        )
    }
    
    /// Attempts to parse the BOM from a data struct.
    ///
    /// The first couple of bytes of the data will be analyzed to determin the encoding.
    /// Getting a `nil` value means that no `BOM` was detected.
    ///
    /// - Parameter data: The data to detect the encoding
    public init?(data: Data) {
        // Make sure we have enough bytes to predict the encoding
        guard data.count > 1 else {
            return nil
        }
        
        self.init(
            bom0: data[0],
            bom1: data[1],
            bom2: data.element(at: 2),
            bom3: data.element(at: 3)
        )
    }
    
    private init?(bom0: UInt8, bom1: UInt8, bom2: UInt8?, bom3: UInt8?) {
        let encoding: String.Encoding
        switch (bom0, bom1, bom2, bom3) {
            case (0x00, 0x00, 0xFE, 0xFF):
                encoding = .utf32BigEndian
            case (0xFF, 0xFE, 0x00, 0x00):
                encoding = .utf32LittleEndian
            case (0xFE, 0xFF, _, _):
                encoding = .utf16BigEndian
            case (0xFF, 0xFE, _, _):
                encoding = .utf16LittleEndian
            case (0xEF, 0xBB, 0xBF, _):
                encoding = .utf8
            default:
                return nil
        }
        self.encoding = encoding
    }
    
    /// The length of the `BOM` in bytes.
    ///
    /// As an example: The length of a UTF-8 BOM is 3 bytes.
    public var length: Int {
        guard let length = Self.length(for: encoding) else {
            assertionFailure("Unsupported Encoding")
            return 0
        }
        return length
    }
    
    /// Get length of the `BOM` in bytes for a given Encoding.
    ///
    /// As an example: The length of a UTF-8 BOM is 3 bytes.
    ///
    /// - Parameter encoding: The given Encoding
    /// - Returns: The length of the `BOM` in bytes for a given Encoding.
    public static func length(for encoding: String.Encoding) -> Int? {
        switch encoding {
            case .utf8:
                return 3
            case .utf16BigEndian, .utf16LittleEndian, .utf16, .unicode:
                return 2
            case .utf32BigEndian, .utf32LittleEndian, .utf32:
                return 4
            default:
                return nil
        }
    }
    
}

private extension Collection where Index: BinaryInteger {
    func element(at index: Index) -> Element? {
        guard index < count else {
            return nil
        }
        return self[index]
    }
}
