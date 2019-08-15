import XCTest
@testable import EFStorage
import KeychainAccess

extension Bool: KeychainStorable {
    public func asKeychainStorable() -> KeychainStorable! {
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
    
    static let defaultText = "Hello, World!"
    
    @EFStorageUserDefaults(forKey: "text",
                           valueIfNotPresent: EFStorageTests.defaultText,
                           persistDefaultContent: true)
    var text: String
    
    @EFStorageUserDefaults(forKey: "wow", valueIfNotPresent: "nah")
    var nsString: NSString
    
    @EFStorageKeychain(forKey: "password", valueIfNotPresent: "")
    var password: String
    
    @EFStorageComposition(EFStorageUserDefaults(forKey: "isNewUser", valueIfNotPresent: false),
                          EFStorageKeychain(forKey: "isNewUser", valueIfNotPresent: false))
    var isNewUser: Bool
    
    @AnyEFStorage(EFStorageKeychain(forKey: "paidBefore", valueIfNotPresent: false)
        + EFStorageUserDefaults(forKey: "paidBefore", valueIfNotPresent: false)
        + EFStorageUserDefaults(forKey: "oldHasPaidBeforeKey", valueIfNotPresent: true))
    var hasPaidBefore: Bool
    
    var storageText: EFStorageUserDefaultsRef<String> = UserDefaults.efStorage.text
    
    func testExample() {
        XCTAssertEqual(text, EFStorageTests.defaultText)
        text = "meow"
        XCTAssertEqual(_text.wrappedValue, "meow")
        _text.removeContentFromUnderlyingStorage()
        XCTAssertEqual(text, EFStorageTests.defaultText)
        XCTAssertEqual(text, UserDefaults.efStorageContents.text)
        XCTAssertEqual(storageText.content, text)
        let hasPaidBeforeRef: EFStorageUserDefaultsRef<Bool> = UserDefaults.efStorage.oldHasPaidBeforeKey
        hasPaidBeforeRef.content = true
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "oldHasPaidBeforeKey"), true)
        debugPrint(efStorages)
        XCTAssertEqual(hasPaidBefore, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
