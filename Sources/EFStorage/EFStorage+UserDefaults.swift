//
//  EFStorage+UserDefaults.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/12.
//

import Foundation

// MARK: - Conformance

extension UserDefaults: EFStorageWrapperBase { }

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
            return baseWrapper.base.efStorage[dynamicMember: key].value
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].value = newValue
        }
    }
    
    subscript<T: UserDefaultsStorable>(dynamicMember key: String) -> T? where Base == UserDefaults.Type {
        get {
            return baseWrapper.base.efStorage[dynamicMember: key].value
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].value = newValue
        }
    }
}

// MARK: - Implementation

/// This class should not be copied nor should it be initialized directly;
/// use `EFStorageUserDefaultsRef.forKey<Content: UserDefaultsStorable>` instead.
public class EFStorageUserDefaultsRef<Content: UserDefaultsStorable>: EFSingleInstanceStorageReference {
    fileprivate let key: String
    private let userDefaults: UserDefaults
    public required init(
        forKeyToBeHeldStrongly key: String, in storage: UserDefaults,
        iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: Bool
    ) {
        self.key = key
        self.userDefaults = storage
        self.value = Content.fromUserDefaults(userDefaults, forKey: key)
    }
    
    public var value: Content? {
        didSet {
            if let newValue = value {
                userDefaults.set(newValue.asUserDefaultsStorable(), forKey: key)
            } else {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}

@propertyWrapper
public struct EFStorageUserDefaults<Content: UserDefaultsStorable>: EFStorage {
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
    
    private let ref: EFStorageUserDefaultsRef<Content>
    public var key: String { return ref.key }
    public init(forKey key: String, in userDefaults: UserDefaults = .standard,
                valueIfNotPresent makeDefaultValue: @escaping @autoclosure () -> Content,
                storeDefaultValueToStorage: Bool = false) {
        self.ref = EFStorageUserDefaultsRef<Content>.forKey(key, in: userDefaults)
        self.makeDefaultContent = makeDefaultValue
        if self.ref.value == nil, storeDefaultValueToStorage {
            self.ref.value = makeDefaultValue()
        }
        self.storeDefaultValueToStorage = storeDefaultValueToStorage
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
