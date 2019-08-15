//
//  EFStorage+Keychain.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/12.
//

import KeychainAccess
import Foundation
import EFStorageCore

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
/// use `EFStorageKeychainRef.forKey<Content: KeychainStorable>` instead.
public class EFStorageKeychainRef<Content: KeychainStorable>: EFSingleInstanceStorageReference {
    public required init(
        iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself ignored: Bool,
        forKey key: String, in storage: Keychain
    ) {
        self.key = key
        self.storage = storage
        self.content = Content.fromKeychain(storage, forKey: key)
    }
    
    public let key: String
    public let storage: Keychain
    public var content: Content? {
        didSet {
            guard let newValue = content else {
                try? storage.remove(key)
                return
            }
            switch newValue.asKeychainStorable() {
            case let string as String:
                try? storage.set(string, key: key)
            case let data as Data:
                try? storage.set(data, key: key)
            default:
                fatalError("\(newValue) of type \(type(of: newValue)) is not storable in keychain")
            }
        }
    }
    
    deinit {
        debugPrint("CLEAR \(String(describing: self)) \(key)")
    }
}

@propertyWrapper
public struct EFStorageKeychain<Content: KeychainStorable>: EFSingleInstanceStorageReferenceWrapper {
    public var _ref: EFStorageKeychainRef<Content>
    public var wrappedValue: Content {
        get {
            if let content = _ref.content { return content }
            let defaultContent = makeDefaultContent()
            if persistDefaultContent { _ref.content = defaultContent }
            return defaultContent
        }
        set { _ref.content = newValue }
    }
    
    public let persistDefaultContent: Bool
    public let makeDefaultContent: () -> Content
    public func removeContentFromUnderlyingStorage() {
        _ref.content = nil
    }
    
    public init(
        iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself ignored: Bool,
        ref: EFStorageKeychainRef<Content>,
        makeDefaultContent: @escaping () -> Content,
        persistDefaultContent: Bool
    ) {
        self._ref = ref
        self.makeDefaultContent = makeDefaultContent
        self.persistDefaultContent = persistDefaultContent
    }
}

extension Keychain: EFUnderlyingStorage {
    public class func makeDefault() -> Self {
        return Self()
    }
    
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
