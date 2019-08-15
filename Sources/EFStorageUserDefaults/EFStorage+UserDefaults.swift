//
//  EFStorage+UserDefaults.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/12.
//

import Foundation
import EFStorageCore

// MARK: - Conformance

extension UserDefaults: EFStorageWrapperBase, EFUnderlyingStorage {
    public class func makeDefault() -> Self {
        if let this = UserDefaults.standard as? Self {
            return this
        } else {
            return Self()
        }
    }
}

/// NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary
public protocol UserDefaultsStorable {
    func asUserDefaultsStorable() -> UserDefaultsStorable!
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self?
}

/*
public extension EFStorageWrapper {
    subscript<T: UserDefaultsStorable, Ref: EFSingleInstanceStorageReference>(
        dynamicMember key: String
    ) -> Ref<T> where Base == EFStorageWrapperBase {
        return Ref<T>.forKey(key, in: base)
    }
    
    subscript<T: UserDefaultsStorable, Ref: EFSingleInstanceStorageReference>(
        dynamicMember key: String
    ) -> Ref<T> where Base == EFStorageWrapperBase.Type {
        return Ref<T>.forKey(key, in: Base.makeDefault())
    }
}

public extension EFStorageContentWrapper {
    subscript<T: UserDefaultsStorable>(dynamicMember key: String) -> T? where Base == EFStorageWrapperBase {
        get {
            return baseWrapper.base.efStorage[dynamicMember: key].content
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].content = newValue
        }
    }
    
    subscript<T: UserDefaultsStorable>(dynamicMember key: String) -> T? where Base == EFStorageWrapperBase.Type {
        get {
            return baseWrapper.base.efStorage[dynamicMember: key].content
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].content = newValue
        }
    }
}
 */

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
            if let newValue = content {
                storage.set(newValue.asUserDefaultsStorable(), forKey: key)
            } else {
                storage.removeObject(forKey: key)
            }
        }
    }
    
    deinit {
        debugPrint("CLEAR \(String(describing: self)) \(key)")
    }
}

@propertyWrapper
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
        iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself ignored: Bool,
        ref: EFStorageUserDefaultsRef<Content>,
        makeDefaultContent: @escaping () -> Content,
        persistDefaultContent: Bool
    ) {
        self._ref = ref
        self.makeDefaultContent = makeDefaultContent
        self.persistDefaultContent = persistDefaultContent
    }
}
