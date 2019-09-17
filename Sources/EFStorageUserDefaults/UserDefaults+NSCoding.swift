//
//  UserDefaults+NSCoding.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/15.
//

import Foundation

public extension UserDefaultsStorable where Self: NSCoding {
    func asUserDefaultsStorable() -> AsIsUserDefaultsStorable! {
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
