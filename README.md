# BOM

A Swift implementation of a byte order mark reader used to guess the encoding of files and data.
Based on the following definition [Wikipedia: Byte order mark](https://en.wikipedia.org/wiki/Byte_order_mark)

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

> Xcode 11+ is required to build Swift-BOM using Swift Package Manager.

To integrate Swift-BOM into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/joseph-elmallah/swift-bom", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

### BOM from Data

`BOM` can parse and identify the encoding of a `Data` object by inspecting the starting bytes.

```swift
if let bom = BOM(data: _your_data_) {
    // A BOM was detected
    print("The Data's encoding is \(bom.encoding)")
} else {
    // There is no BOM in the data
    print("The Data contains no BOM")
}
```

### BOM from a File on disk

`BOM` can detect encoding of files saved on disk lazily by inspecting the first couple of bytes. This is advantageous as the file doesn't need to be fully loaded or parsed.

```swift
do {

    if let bom = try BOM(fileURL: _path_to_file_) {
        // A BOM was detected
        print("The Data's encoding is \(bom.encoding)")
    } else {
        // There is no BOM in the data
        print("The Data contains no BOM")
    }

} catch {
    print("An error in reading the file occurred \(error)")
}
```

## Tests

The package contains test data and test cases. One special file named `testDataGeneration.sh` can be used to regenerate the test files or tweak them.

## License

Swift-BOM is released under the MIT license. See LICENSE for details.
