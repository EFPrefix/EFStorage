//
//  KeychainAccess+Primitives.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import KeychainAccess
import Foundation

extension String: KeychainAccessStorable {
    public func asKeychainStorable() -> KeychainAccessStorable! {
        return self
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> String? {
        return try? keychain.getString(key)
    }
}

extension Data: KeychainAccessStorable {
    public func asKeychainStorable() -> KeychainAccessStorable! {
        return self
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Data? {
        return try? keychain.getData(key)
    }
}
