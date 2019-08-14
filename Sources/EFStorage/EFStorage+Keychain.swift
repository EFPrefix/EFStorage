//
//  EFStorage+Keychain.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/12.
//

import KeychainAccess
import Foundation

// MARK: - Value Protocol

public protocol KeychainStorable {
    func asKeychainStorable() -> KeychainStorable!
    static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self?
}

// MARK: - Natives

extension String: KeychainStorable {
    public func asKeychainStorable() -> KeychainStorable! {
        return self
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return try? keychain.getString(key)
    }
}

extension Data: KeychainStorable {
    public func asKeychainStorable() -> KeychainStorable! {
        return self
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return try? keychain.getData(key)
    }
}

// MARK: - NSCoding

public extension KeychainStorable where Self: NSCoding {
    func asKeychainStorable() -> KeychainStorable! {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        guard let data = try? keychain.getData(key) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Self
    }
}

extension NSArray: KeychainStorable { }
extension NSNumber: KeychainStorable { }
extension NSString: KeychainStorable { }

// MARK: - RawRepresentable

public extension KeychainStorable where Self: RawRepresentable, Self.RawValue: KeychainStorable {
    func asKeychainStorable() -> KeychainStorable! {
        return rawValue.asKeychainStorable()
    }
    static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return RawValue.fromKeychain(keychain, forKey: key)
            .flatMap(Self.init(rawValue:))
    }
}

public extension KeychainStorable where Self: Codable {
    func asKeychainStorable() -> KeychainStorable! {
        return try? JSONEncoder().encode(self).asKeychainStorable()
    }
    static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return Data.fromKeychain(keychain, forKey: key).flatMap {
            try? JSONDecoder().decode(Self.self, from: $0)
        }
    }
}

// MARK: - Implementation

/// This class should not be copied nor should it be initialized directly;
/// use `EFStorageUserDefaultsRef.forKey<Content: UserDefaultsStorable>` instead.
public class EFStorageKeychainRef<Content: KeychainStorable>: EFSingleInstanceStorageReference, CustomDebugStringConvertible {
    fileprivate let key: String
    private let keychain: Keychain
    public required init(
        forKey key: String, in storage: Keychain,
        iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: Bool
    ) {
        self.key = key
        self.keychain = storage
        self.value = Content.fromKeychain(keychain, forKey: key)
    }
    
    public var value: Content? {
        didSet {
            guard let newValue = value else {
                try? keychain.remove(key)
                return
            }
            switch newValue.asKeychainStorable() {
            case let string as String:
                try? keychain.set(string, key: key)
            case let data as Data:
                try? keychain.set(data, key: key)
            default:
                fatalError("\(newValue) of type \(type(of: newValue)) is not storable in keychain")
            }
        }
    }
    
    public var debugDescription: String {
        return "KY[\(key)] = \((value ?? "nil") as Any)"
    }
    
    deinit {
        debugPrint("CLEAR \(String(describing: self)) \(key)")
    }
}

@propertyWrapper
public struct EFStorageKeychain<Content: KeychainStorable>: EFStorage, CustomDebugStringConvertible {
    private let storeDefaultValueToStorage: Bool
    public let makeDefaultContent: () -> Content
    
    public var content: Content? {
        get { return ref.value }
        set { ref.value = newValue }
    }
    public var wrappedValue: Content {
        get {
            if let value = ref.value { return value }
            let defaultValue = makeDefaultContent()
            if storeDefaultValueToStorage { ref.value = defaultValue }
            return defaultValue
        }
        set { ref.value = newValue }
    }
    public func remove() {
        ref.value = nil
    }
    
    private let ref: EFStorageKeychainRef<Content>
    public var key: String { return ref.key }
    public init(forKey key: String, in keychain: Keychain = Keychain(),
                valueIfNotPresent makeDefaultValue: @escaping @autoclosure () -> Content,
                storeDefaultValueToStorage: Bool = false) {
        self.ref = EFStorageKeychainRef<Content>.forKey(key, in: keychain)
        self.makeDefaultContent = makeDefaultValue
        if self.ref.value == nil, storeDefaultValueToStorage {
            self.ref.value = makeDefaultValue()
        }
        self.storeDefaultValueToStorage = storeDefaultValueToStorage
    }
    
    public var debugDescription: String {
        return "KY[\(key)] = \((ref.value ?? "nil") as Any) ?? \(makeDefaultContent())"
    }
}

extension Keychain: Equatable {
    public static func == (lhs: Keychain, rhs: Keychain) -> Bool {
        guard lhs.itemClass == rhs.itemClass else { return false }
        switch lhs.itemClass {
        case .genericPassword:
            return lhs.service == rhs.service && lhs.accessGroup == rhs.accessGroup
        case .internetPassword:
            return lhs.server == rhs.server && lhs.protocolType == rhs.protocolType
                && lhs.authenticationType == rhs.authenticationType
        }
    }
}
