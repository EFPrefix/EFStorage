//
//  KeychainAccess+Codable.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import KeychainAccess
import Foundation

public extension KeychainAccessStorable where Self: Codable {
    func asKeychainAccessStorable() -> Result<AsIsKeychainAccessStorable, Error> {
        return Result { try JSONEncoder().encode(self) }
            .mapError { print($0);return $0 }
            .flatMap { $0.asKeychainAccessStorable() }
    }
    static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return Data.fromKeychain(keychain, forKey: key).flatMap {
            try? JSONDecoder().decode(Self.self, from: $0)
        }
    }
}
