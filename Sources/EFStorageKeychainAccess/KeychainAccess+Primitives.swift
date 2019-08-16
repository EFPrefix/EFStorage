//
//  File.swift
//  
//
//  Created by ApolloZhu on 2019/8/16.
//

import KeychainAccess
import Foundation

extension String: KeychainAccessStorable {
    public func asKeychainStorable() -> KeychainAccessStorable! {
        return self
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return try? keychain.getString(key)
    }
}

extension Data: KeychainAccessStorable {
    public func asKeychainStorable() -> KeychainAccessStorable! {
        return self
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return try? keychain.getData(key)
    }
}
