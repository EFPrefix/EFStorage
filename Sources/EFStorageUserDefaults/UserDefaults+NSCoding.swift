//
//  File.swift
//  
//
//  Created by ApolloZhu on 2019/8/15.
//

import Foundation

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
