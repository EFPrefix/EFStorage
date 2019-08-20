import XCTest
#if canImport(EFStorageCore)
@testable import EFStorageCore
@testable import EFStorageKeychainAccess
@testable import EFStorageUserDefaults
@testable import EFStorageYYCache
#else
@testable import EFStorage
#endif
import KeychainAccess

extension Bool: KeychainAccessStorable {
    public func asKeychainStorable() -> KeychainAccessStorable! {
        return "\(self)"
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Bool? {
        guard let string = try? keychain.getString(key) else { return nil }
        return string == "true"
    }
}

final class EFStorageTests: XCTestCase {
    func testReset() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        try! Keychain().removeAll()
    }
    
    static let defaultText = "Hello, World! Swift 5 is boring"
    
    var storageText = EFStorageUserDefaultsRef<String>.forKey("text")
    
    func testExample() {
        storageText.content = EFStorageTests.defaultText
        XCTAssertTrue(UserDefaults.standard.object(forKey: "text") is String, "IS NOT STRING")
        XCTAssertEqual(UserDefaults.standard.object(forKey: "text") as? String, storageText.content)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
