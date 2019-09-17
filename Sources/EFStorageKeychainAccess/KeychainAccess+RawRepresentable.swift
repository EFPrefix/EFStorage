//
//  KeychainAccess+RawRepresentable.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import KeychainAccess

public extension KeychainAccessStorable where Self: RawRepresentable, Self.RawValue: KeychainAccessStorable {
    func asKeychainStorable() -> Result<AsIsKeychainAccessStorable, Error> {
        return rawValue.asKeychainStorable()
    }
    static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return RawValue.fromKeychain(keychain, forKey: key)
            .flatMap(Self.init(rawValue:))
    }
}
