//
//  EFStorage+UserDefaults.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/12.
//

import Foundation

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

public extension EFStorageWrapper {
    subscript<T: UserDefaultsStorable>(dynamicMember key: String) -> EFStorageUserDefaultsRef<T> where Base == UserDefaults {
        return EFStorageUserDefaultsRef<T>.forKey(key, in: base)
    }
    
    subscript<T: UserDefaultsStorable>(dynamicMember key: String) -> EFStorageUserDefaultsRef<T> where Base == UserDefaults.Type {
        return EFStorageUserDefaultsRef<T>.forKey(key, in: UserDefaults.standard)
    }
}

public extension EFStorageContentWrapper {
    subscript<T: UserDefaultsStorable>(dynamicMember key: String) -> T? where Base == UserDefaults {
        get {
            return baseWrapper.base.efStorage[dynamicMember: key].content
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].content = newValue
        }
    }
    
    subscript<T: UserDefaultsStorable>(dynamicMember key: String) -> T? where Base == UserDefaults.Type {
        get {
            return baseWrapper.base.efStorage[dynamicMember: key].content
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].content = newValue
        }
    }
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

// MARK: - Value Protocol

/// NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary
public protocol UserDefaultsStorable {
    func asUserDefaultsStorable() -> UserDefaultsStorable!
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self?
}

// MARK: - Natives

protocol AsIsUserDefaultsStorable: UserDefaultsStorable { }

extension AsIsUserDefaultsStorable {
    public func asUserDefaultsStorable() -> UserDefaultsStorable! {
        return self
    }
    public static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        guard let object = userDefaults.object(forKey: key) else { return nil }
        return object as? Self
    }
}

extension String: AsIsUserDefaultsStorable {
    public static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> String? {
        return userDefaults.string(forKey: key)
    }
}
extension Bool: AsIsUserDefaultsStorable { }
extension Int: AsIsUserDefaultsStorable { }
extension Float: AsIsUserDefaultsStorable { }
extension Double: AsIsUserDefaultsStorable { }
extension Data: AsIsUserDefaultsStorable { }

extension Dictionary: AsIsUserDefaultsStorable
where Key == String, Value: AsIsUserDefaultsStorable { }
extension Dictionary: UserDefaultsStorable
where Key == String, Value: AsIsUserDefaultsStorable { }

extension Array: AsIsUserDefaultsStorable
where Element: AsIsUserDefaultsStorable { }
extension Array: UserDefaultsStorable
where Element: AsIsUserDefaultsStorable { }

extension URL: UserDefaultsStorable {
    public func asUserDefaultsStorable() -> UserDefaultsStorable! {
        return absoluteString
    }
    public static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> URL? {
        return userDefaults.url(forKey: key)
    }
}

// MARK: - NSCoding

public extension UserDefaultsStorable where Self: NSCoding {
    func asUserDefaultsStorable() -> UserDefaultsStorable! {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Self
    }
}

extension NSArray: UserDefaultsStorable { }
extension NSNumber: UserDefaultsStorable { }
extension NSString: UserDefaultsStorable { }

public extension EFStorageUserDefaults where Content: NSString {
    var string: String {
        mutating get {
            return wrappedValue as String
        }
        set {
            wrappedValue = newValue as NSString as! Content
        }
    }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<String, Value>) -> Value {
        mutating get { return string[keyPath: keyPath] }
    }
    
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<String, Value>) -> Value {
        mutating get { return string[keyPath: keyPath] }
        set { string[keyPath: keyPath] = newValue }
    }
}

// MARK: - RawRepresentable

public extension UserDefaultsStorable where Self: RawRepresentable, Self.RawValue: UserDefaultsStorable {
    func asUserDefaultsStorable() -> UserDefaultsStorable! {
        return rawValue.asUserDefaultsStorable()
    }
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        return RawValue.fromUserDefaults(userDefaults, forKey: key)
            .flatMap(Self.init(rawValue:))
    }
}

public extension UserDefaultsStorable where Self: Codable {
    func asUserDefaultsStorable() -> UserDefaultsStorable! {
        return try! JSONEncoder().encode(self).asUserDefaultsStorable()
    }
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        return Data.fromUserDefaults(userDefaults, forKey: key).flatMap {
            try? JSONDecoder().decode(Self.self, from: $0)
        }
    }
}
