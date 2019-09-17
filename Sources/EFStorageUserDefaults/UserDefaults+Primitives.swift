//
//  UserDefaults+Primitives.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/15.
//

import Foundation

extension URL: UserDefaultsStorable {
    public func asUserDefaultsStorable() -> AsIsUserDefaultsStorable! {
        return absoluteString
    }
    public static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> URL? {
        return userDefaults.url(forKey: key)
    }
}

// MARK: - As Is UserDefaults Storable
public protocol AsIsUserDefaultsStorable: UserDefaultsStorable { }

extension AsIsUserDefaultsStorable {
    public func asUserDefaultsStorable() -> AsIsUserDefaultsStorable! {
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
extension Data: AsIsUserDefaultsStorable { }
extension Date: AsIsUserDefaultsStorable { }

extension Float: AsIsUserDefaultsStorable { }
extension Double: AsIsUserDefaultsStorable { }
#if canImport(CoreGraphics)
// CGFloat is in CoreGraphics on Apple platforms, but in Foundation on others.
import CoreGraphics
#endif
extension CGFloat: AsIsUserDefaultsStorable { }

extension Int: AsIsUserDefaultsStorable { }
extension Int8: AsIsUserDefaultsStorable { }
extension UInt8: AsIsUserDefaultsStorable { }
extension Int16: AsIsUserDefaultsStorable { }
extension UInt16: AsIsUserDefaultsStorable { }
extension Int32: AsIsUserDefaultsStorable { }
extension UInt32: AsIsUserDefaultsStorable { }
extension Int64: AsIsUserDefaultsStorable { }
extension UInt64: AsIsUserDefaultsStorable { }

extension Dictionary: AsIsUserDefaultsStorable, UserDefaultsStorable
where Key == String, Value: AsIsUserDefaultsStorable { }

extension Array: AsIsUserDefaultsStorable, UserDefaultsStorable
where Element: AsIsUserDefaultsStorable { }
