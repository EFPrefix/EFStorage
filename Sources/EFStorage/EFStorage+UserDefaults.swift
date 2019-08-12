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


extension UserDefaults {
    fileprivate static var efStorages = NSMapTable<NSString, AnyObject>.weakToWeakObjects()
}

/// This class should not be copied nor should it be initialized directly;
/// use `EFStorageUserDefaultsRef.forKey<T: UserDefaultsStorable>` instead.
@dynamicMemberLookup
public class EFStorageUserDefaultsRef<T: UserDefaultsStorable> {
    fileprivate let key: String
    private let userDefaults: UserDefaults
    private init(forKey key: String, in userDefaults: UserDefaults) {
        self.key = key
        self.userDefaults = userDefaults
    }
    
    public var value: T? {
        didSet {
            if let newValue = value {
                userDefaults.set(newValue.asUserDefaultsStorable(), forKey: key)
            } else {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    /// Returns the unique instance for key in the specified `userDefaults`.
    /// - Parameter key: user defaults key.
    /// - Parameter userDefaults: `UserDefaults` instance where key is to be stored.
    ///
    /// - Important: does not support using the same key across different user defaults.
    public static func forKey(_ key: String, in userDefaults: UserDefaults) -> EFStorageUserDefaultsRef<T> {
        if let object = UserDefaults.efStorages.object(forKey: key as NSString),
            let storage = object as? EFStorageUserDefaultsRef<T> {
            assert(storage.userDefaults == userDefaults, "Identical Key In Different User Defaults")
            return storage
        }
        let newStorage = EFStorageUserDefaultsRef<T>(forKey: key, in: userDefaults)
        UserDefaults.efStorages.setObject(newStorage, forKey: key as NSString)
        return newStorage
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<T, Value>) -> Value? {
        get { return value?[keyPath: keyPath] }
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<T, Value>) -> Value? {
        get { return value?[keyPath: keyPath] }
        set { newValue.map { value?[keyPath: keyPath] = $0 } }
    }
}

@propertyWrapper
@dynamicMemberLookup
public struct EFStorageUserDefaults<T: UserDefaultsStorable>: EFStorage {
    private let ref: EFStorageUserDefaultsRef<T>
    public var key: String { return ref.key }
    public var wrappedValue: T {
        mutating get {
            if let value = ref.value { return value }
            let value = defaultValue
            if storeDefaultValueToStorage { ref.value = value }
            return defaultValue
        }
        set { ref.value = newValue }
    }
    public func remove() {
        ref.value = nil
    }
    private let makeDefaultValue: () -> T
    private lazy var defaultValue: T = makeDefaultValue()
    private let storeDefaultValueToStorage: Bool
    
    public init(forKey key: String, in userDefaults: UserDefaults = .standard,
                defaultsTo defaultValue: @escaping @autoclosure () -> T,
                storeDefaultValueToStorage: Bool = false) {
        self.ref = EFStorageUserDefaultsRef<T>.forKey(key, in: userDefaults)
        self.makeDefaultValue = defaultValue
        self.ref.value = T.fromUserDefaults(userDefaults, forKey: key)
        self.storeDefaultValueToStorage = storeDefaultValueToStorage
    }
    
    public subscript<Value>(dynamicMember keyPath: KeyPath<T, Value>) -> Value {
        mutating get { return wrappedValue[keyPath: keyPath] }
    }
    
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<T, Value>) -> Value {
        mutating get { return wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
}

// MARK: - Value Protocol

/// NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary
public protocol UserDefaultsStorable {
    func asUserDefaultsStorable() -> UserDefaultsStorable
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self?
}

// MARK: - Natives

protocol AsIsUserDefaultsStorable: UserDefaultsStorable { }

extension AsIsUserDefaultsStorable {
    public func asUserDefaultsStorable() -> UserDefaultsStorable {
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
    public func asUserDefaultsStorable() -> UserDefaultsStorable {
        return absoluteString
    }
    public static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> URL? {
        return userDefaults.url(forKey: key)
    }
}

// MARK: - NSCoding

extension UserDefaultsStorable where Self: NSCoding {
    public func asUserDefaultsStorable() -> UserDefaultsStorable {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    public static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Self
    }
}

extension NSArray: UserDefaultsStorable { }
extension NSNumber: UserDefaultsStorable { }
extension NSString: UserDefaultsStorable { }

public extension EFStorageUserDefaults where T: NSString {
    var string: String {
        mutating get {
            return wrappedValue as String
        }
        set {
            wrappedValue = newValue as NSString as! T
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
    func asUserDefaultsStorable() -> UserDefaultsStorable {
        return rawValue.asUserDefaultsStorable()
    }
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        return RawValue.fromUserDefaults(userDefaults, forKey: key)
            .flatMap(Self.init(rawValue:))
    }
}

public extension UserDefaultsStorable where Self: Codable {
    func asUserDefaultsStorable() -> UserDefaultsStorable {
        return try! JSONEncoder().encode(self).asUserDefaultsStorable()
    }
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        return Data.fromUserDefaults(userDefaults, forKey: key).flatMap {
            try? JSONDecoder().decode(Self.self, from: $0)
        }
    }
}
