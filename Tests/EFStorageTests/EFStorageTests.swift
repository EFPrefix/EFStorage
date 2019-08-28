import XCTest
#if canImport(EFStorageCore)
@testable import EFStorageCore
@testable import EFStorageKeychainAccess
@testable import EFStorageUserDefaults
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
    
    static let defaultText = "Hello, World!"
    
    @EFStorageUserDefaults(forKey: "text",
                           defaultsTo: EFStorageTests.defaultText,
                           persistDefaultContent: true)
    var text: String
    
    @EFStorageUserDefaults(forKey: "wow", defaultsTo: "nah")
    var nsString: NSString
    
    @EFStorageKeychainAccess(forKey: "password", defaultsTo: "")
    var password: String
    
    @EFStorageComposition(EFStorageUserDefaults(forKey: "isNewUser", defaultsTo: false),
                          EFStorageKeychainAccess(forKey: "isNewUser", defaultsTo: false))
    var isNewUser: Bool
    
    @AnyEFStorage(EFStorageKeychainAccess(forKey: "paidBefore", defaultsTo: false)
        + EFStorageUserDefaults(forKey: "paidBefore", defaultsTo: false)
        + EFStorageUserDefaults(forKey: "oldHasPaidBeforeKey", defaultsTo: true,
                                persistDefaultContent: true))
    var hasPaidBefore: Bool
    
    
    @EFStorageComposition(
        EFStorageUserDefaults<String>(forKey: "sameKey", defaultsTo: "Nah"),
        EFStorageMigrate(from: EFStorageUserDefaults<Int>(forKey: "sameKey",
                                                          defaultsTo: 1551,
                                                          persistDefaultContent: true),
                         by: { number in String(number) })
    )
    var mixedType: String
    
    var storageText: EFStorageUserDefaultsRef<String> = UserDefaults.efStorage.text
    
    private func printValue<T: CustomStringConvertible>(_ t: T?, ofType type: T.Type,
                                                        or defaultValue: @autoclosure () -> String) {
        print("VALUE \(t?.description ?? defaultValue())")
    }
    
    func testExample() {
        printValue(UserDefaults.efStorage.nonExisting, ofType: CGFloat.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: Data.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: NSArray.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: Int8.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: Int16.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: Int32.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: Int64.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: UInt8.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: UInt16.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: UInt32.self, or: "SHOULD DISAPPEAR")
        printValue(UserDefaults.efStorage.nonExisting, ofType: UInt64.self, or: "SHOULD DISAPPEAR")
        XCTAssertEqual(text, EFStorageTests.defaultText)
        text = "meow"
        XCTAssertEqual(_text.wrappedValue, "meow")
        _text.removeContentFromUnderlyingStorage()
        XCTAssertEqual(text, EFStorageTests.defaultText)
        XCTAssertEqual(text, UserDefaults.efStorage.text)
        XCTAssertEqual(storageText.content, text)
        let hasPaidBeforeRef: EFStorageUserDefaultsRef<Bool> = UserDefaults.efStorage.oldHasPaidBeforeKey
        XCTAssertEqual(hasPaidBeforeRef.content, true)
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "oldHasPaidBeforeKey"), true)
        _EFStorageInternal.read {
            let wasted = $0.values.lazy.filter { $0.keyEnumerator().allObjects.isEmpty }.count
            print("""
            ----- SSTAT START--------------------
            
            WASTE \(wasted)
            USING \($0.count - wasted)
            TOTAL \($0.count)
            LIMIT \($0.capacity)
            
            STORE \($0)
            
            ----- SSTAT END-----------------------
            """)
        }
        XCTAssertEqual(hasPaidBefore, true)
        XCTAssertEqual(mixedType, "1551")
        mixedType = "Brand New"
        XCTAssertTrue(UserDefaults.standard.object(forKey: "sameKey") is String, "IS NOT STRING")
        XCTAssertFalse(UserDefaults.standard.object(forKey: "sameKey") is Int, "IS NUMBER")
        XCTAssertEqual(mixedType, "Brand New")
        XCTAssertEqual(UserDefaults.efStorage.sameKey, "Brand New")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
