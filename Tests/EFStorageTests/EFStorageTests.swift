import XCTest
@testable import EFStorage

final class EFStorageTests: XCTestCase {
    static let defaultText = "Hello, World!"
    
    @EFStorageUserDefaults(forKey: "text", defaultsTo: EFStorageTests.defaultText, storeDefaultValueToStorage: true)
    var text: String
    
    @EFStorageUserDefaults(forKey: "wow", defaultsTo: "nah")
    var nsString: NSString
    
    var storage: EFStorageUserDefaultsRef<String> = UserDefaults.efStorage.text
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(text, EFStorageTests.defaultText)
        text = "meow"
        XCTAssertEqual(_text.wrappedValue, "meow")
        _text.remove()
        XCTAssertEqual(text, EFStorageTests.defaultText)
        XCTAssertEqual(text, UserDefaults.efStorageContents.text)
        XCTAssertEqual(storage.value, text)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
