//
//  UserDefaults+Codable.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/15.
//

import Foundation

public extension UserDefaultsStorable where Self: Codable {
    func asUserDefaultsStorable() -> UserDefaultsStorable! {
        return try? JSONEncoder().encode(self).asUserDefaultsStorable()
    }
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        return Data.fromUserDefaults(userDefaults, forKey: key).flatMap {
            try? JSONDecoder().decode(Self.self, from: $0)
        }
    }
}
