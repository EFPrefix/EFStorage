//
//  KeychainAccess+Codable.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import KeychainAccess
import Foundation

public extension KeychainAccessStorable where Self: Codable {
    func asKeychainStorable() -> KeychainAccessStorable! {
        do {
            return try JSONEncoder().encode(self).asKeychainStorable()
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Self? {
        return Data.fromKeychain(keychain, forKey: key).flatMap {
            try? JSONDecoder().decode(Self.self, from: $0)
        }
    }
}
