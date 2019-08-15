//
//  File.swift
//  
//
//  Created by ApolloZhu on 2019/8/15.
//

import Foundation

extension URL: UserDefaultsStorable {
    public func asUserDefaultsStorable() -> UserDefaultsStorable! {
        return absoluteString
    }
    public static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> URL? {
        return userDefaults.url(forKey: key)
    }
}

// MARK: - As Is UserDefaults Storable

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
extension Data: AsIsUserDefaultsStorable { }
extension Date: AsIsUserDefaultsStorable { }

extension Float: AsIsUserDefaultsStorable { }
extension Double: AsIsUserDefaultsStorable { }
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

extension Dictionary: AsIsUserDefaultsStorable
where Key == String, Value: AsIsUserDefaultsStorable { }
extension Dictionary: UserDefaultsStorable
where Key == String, Value: AsIsUserDefaultsStorable { }

extension Array: AsIsUserDefaultsStorable
where Element: AsIsUserDefaultsStorable { }
extension Array: UserDefaultsStorable
where Element: AsIsUserDefaultsStorable { }
