//
//  EFStorage+UserDefaults.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/12.
//

import Foundation
#if canImport(EFStorageCore)
import EFStorageCore
#endif

extension UserDefaults: EFUnderlyingStorage { }

extension EFUnderlyingStorage where Self: UserDefaults {
    public dynamic static func makeDefault() -> Self {
        return (UserDefaults.standard as? Self) ?? Self()
    }
}

/// NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary
public protocol UserDefaultsStorable {
    func asUserDefaultsStorable() -> UserDefaultsStorable!
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self?
}

// MARK: - Implementation

/// This class should not be copied nor should it be initialized directly;
/// use `EFStorageUserDefaultsRef.forKey<Content: UserDefaultsStorable>` instead.
public class EFStorageUserDefaultsRef<Content: UserDefaultsStorable>: EFSingleInstanceStorageReference {
    public required init(
        iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: Bool,
        forKey key: String, in storage: UserDefaults
    ) {
        self.key = key
        self.storage = storage
        self.content = Content.fromUserDefaults(storage, forKey: key)
    }
    
    public let key: String
    public let storage: UserDefaults
    public var content: Content? {
        didSet {
            guard let newValue = content else {
                return storage.removeObject(forKey: key)
            }
            guard let storable = newValue.asUserDefaultsStorable() else {
                assertionFailure("""
                \(newValue) of type \(type(of: newValue)) \
                is not storable in user defaults.
                """)
                return storage.removeObject(forKey: key)
            }
            storage.set(storable, forKey: key)
        }
    }
    
    deinit {
        _efStorageLog("CLEAR \(String(describing: self)) \(key)")
    }
}

public struct EFStorageUserDefaults<Content: UserDefaultsStorable>: EFSingleInstanceStorageReferenceWrapper {
    public var _ref: EFStorageUserDefaultsRef<Content>
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
        __ref: EFStorageUserDefaultsRef<Content>,
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
    subscript<T: UserDefaultsStorable>(
        dynamicMember key: String
    ) -> T? where Base == UserDefaults {
        get {
            return EFStorageUserDefaultsRef.forKey(key, in: base).content
        }
        set {
            EFStorageUserDefaultsRef.forKey(key, in: base).content = newValue
        }
    }
    
    subscript<T: UserDefaultsStorable>(
        dynamicMember key: String
    ) -> T? where Base == UserDefaults.Type {
        get {
            return EFStorageUserDefaultsRef.forKey(key, in: UserDefaults.makeDefault()).content
        }
        set {
            EFStorageUserDefaultsRef.forKey(key, in: UserDefaults.makeDefault()).content = newValue
        }
    }
}
