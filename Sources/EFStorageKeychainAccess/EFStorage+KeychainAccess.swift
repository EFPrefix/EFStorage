//
//  EFStorage+Keychain.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/12.
//

import KeychainAccess
import Foundation
#if canImport(EFStorageCore)
import EFStorageCore
#endif

extension Keychain: EFUnderlyingStorage {
    public dynamic class func makeDefault() -> Self {
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

public enum AsIsKeychainAccessStorable {
    case string(String)
    case data(Data)
}

public protocol KeychainAccessStorable {
    func asKeychainAccessStorable() -> Result<AsIsKeychainAccessStorable, Error>
    static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self?
}

// MARK: - Implementation

/// This class should not be copied nor should it be initialized directly;
/// use `EFStorageKeychainRef.forKey<Content: KeychainStorable>` instead.
public class EFStorageKeychainAccessRef<Content: KeychainAccessStorable>: EFSingleInstanceStorageReference {
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
            switch newValue.asKeychainAccessStorable() {
            case .success(.string(let string)):
                do {
                    try storage.set(string, key: key)
                } catch {
                    onStorageFailure(error)
                }
            case .success(.data(let data)):
                do {
                    try storage.set(data, key: key)
                } catch {
                    onStorageFailure(error)
                }
            case .failure(let error):
                onConversionFailure(for: newValue, dueTo: error)
            }
        }
    }
    
    public dynamic func onStorageFailure(_ error: Error) {
        assertionFailure("keychain failed to save because \(error.localizedDescription)")
    }
    
    public dynamic func onConversionFailure(for content: Content, dueTo error: Error) {
        assertionFailure("""
        \(content) of type \(type(of: content)) \
        is not storable in keychain because \(error.localizedDescription)
        """)
    }
    
    deinit {
        _efStorageLog("CLEAR \(String(describing: self))")
    }
}

@propertyWrapper
public struct EFStorageKeychainAccess<Content: KeychainAccessStorable>: EFSingleInstanceStorageReferenceWrapper {
    public var _ref: EFStorageKeychainAccessRef<Content>
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
        __ref: EFStorageKeychainAccessRef<Content>,
        makeDefaultContent: @escaping () -> Content,
        persistDefaultContent: Bool
    ) {
        self._ref = __ref
        self.makeDefaultContent = makeDefaultContent
        self.persistDefaultContent = persistDefaultContent
    }
}

// MARK: - Dynamic Member Lookup

public extension EFUnderlyingStorageWrapper {
    subscript<T: KeychainAccessStorable>(
        dynamicMember key: String
    ) -> T? where Base == Keychain {
        get {
            return EFStorageKeychainAccessRef.forKey(key, in: base).content
        }
        set {
            EFStorageKeychainAccessRef.forKey(key, in: base).content = newValue
        }
    }
    
    subscript<T: KeychainAccessStorable>(
        dynamicMember key: String
    ) -> T? where Base == Keychain.Type {
        get {
            return EFStorageKeychainAccessRef.forKey(key).content
        }
        set {
            EFStorageKeychainAccessRef.forKey(key).content = newValue
        }
    }
}
