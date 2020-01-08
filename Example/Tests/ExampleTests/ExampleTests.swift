import XCTest
import class Foundation.Bundle

final class ExampleTests: XCTestCase {
    func testExample() throws {
        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("Example")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = try XCTUnwrap(String(data: data, encoding: .utf8))
        
        let endOfFirstLine = try XCTUnwrap(output.firstIndex(of: "\n"))
        let userDefaults = output[..<endOfFirstLine]
        
        XCTAssertEqual(output, """
        \(userDefaults)
        EFStorage ALLOC EFStorageUserDefaultsRef<String>
        EFStorage CREAT EFStorageUserDefaultsRef<String> catSound IN \(userDefaults)
        nyan
        EFStorage FETCH EFStorageUserDefaultsRef<String> catSound FROM \(userDefaults)
        nyan
        EFStorage FETCH EFStorageUserDefaultsRef<String> catSound FROM \(userDefaults)
        meow
        meow
        EFStorage FETCH EFStorageUserDefaultsRef<String> catSound FROM \(userDefaults)
        EFStorage FETCH EFStorageUserDefaultsRef<String> catSound FROM \(userDefaults)
        喵
        
        """)
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
