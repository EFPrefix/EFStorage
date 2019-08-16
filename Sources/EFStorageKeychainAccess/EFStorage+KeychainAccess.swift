//
//  EFStorage+Keychain.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/12.
//

import KeychainAccess
import Foundation
import EFStorageCore

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

public protocol KeychainAccessStorable {
    func asKeychainStorable() -> KeychainAccessStorable!
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