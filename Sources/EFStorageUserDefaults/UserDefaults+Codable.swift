//
//  UserDefaults+Codable.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/15.
//

import Foundation

public extension UserDefaultsStorable where Self: Codable {
    func asUserDefaultsStorable() -> UserDefaultsStorable! {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            return onConversionFailure(dueTo: error)
        }
    }
    
    dynamic func onConversionFailure(dueTo error: Error) -> UserDefaultsStorable! {
        assertionFailure(error.localizedDescription)
        return nil
    }
    
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        return Data.fromUserDefaults(userDefaults, forKey: key).flatMap {
            try? JSONDecoder().decode(Self.self, from: $0)
        }
    }
}
