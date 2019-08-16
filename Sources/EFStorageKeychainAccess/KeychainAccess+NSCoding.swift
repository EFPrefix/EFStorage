//
//  File.swift
//  
//
//  Created by ApolloZhu on 2019/8/16.
//

import KeychainAccess
import Foundation

public extension KeychainAccessStorable where Self: NSCoding {
    func asKeychainStorable() -> KeychainAccessStorable! {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        guard let data = try? keychain.getData(key) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Self
    }
}

extension NSArray: KeychainAccessStorable { }
extension NSNumber: KeychainAccessStorable { }
extension NSString: KeychainAccessStorable { }