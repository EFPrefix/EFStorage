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
    static let defaultText = "Hello, World!"
    
    @EFStorageUserDefaults(forKey: "text",
                           valueIfNotPresent: EFStorageTests.defaultText,
                           storeDefaultValueToStorage: true)
    var text: String
    
    @EFStorageUserDefaults(forKey: "wow", valueIfNotPresent: "nah")
    var nsString: NSString
    
    @EFStorageKeychain(forKey: "password", valueIfNotPresent: "")
    var password: String
    
    @EFStorageComposition(EFStorageUserDefaults(forKey: "isNewUser", valueIfNotPresent: false),
                          EFStorageKeychain(forKey: "isNewUser", valueIfNotPresent: false))
    var isNewUser: Bool
    
    @AnyEFStorage(EFStorageKeychain(forKey: "paidBefore", valueIfNotPresent: false, storeDefaultValueToStorage: false)
        + EFStorageUserDefaults(forKey: "paidBefore", valueIfNotPresent: false, storeDefaultValueToStorage: false)
        + EFStorageUserDefaults(forKey: "oldHasPaidBeforeKey", valueIfNotPresent: true))
    var hasPaidBefore: Bool
    
    var storageText: EFStorageUserDefaultsRef<String> = UserDefaults.efStorage.text
    
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
        XCTAssertEqual(storageText.value, text)
        let hasPaidBeforeRef: EFStorageUserDefaultsRef<Bool> = UserDefaults.efStorage.oldHasPaidBeforeKey
        hasPaidBeforeRef.value = true
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "oldHasPaidBeforeKey"), true)
        debugPrint(efStorages)
        XCTAssertEqual(hasPaidBefore, true)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
