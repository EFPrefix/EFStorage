//
//  KeychainAccess+Primitives.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import KeychainAccess
import Foundation

extension String: KeychainAccessStorable {
    public func asKeychainStorable() -> Result<AsIsKeychainAccessStorable, Error> {
        return .success(.string(self))
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return try? keychain.getString(key)
    }
}

extension Data: KeychainAccessStorable {
    public func asKeychainStorable() -> Result<AsIsKeychainAccessStorable, Error> {
        return .success(.data(self))
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return try? keychain.getData(key)
    }
}
