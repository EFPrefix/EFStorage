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

class StorageKeychain<T: KeychainStorable> {
    public let key: String
    private let keychain: Keychain
    public var value: T? {
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

    init(key: String, in keychain: Keychain) {
        self.key = key
        self.keychain = keychain
        self.value = T.fromKeychain(keychain, forKey: key)
    }
}

