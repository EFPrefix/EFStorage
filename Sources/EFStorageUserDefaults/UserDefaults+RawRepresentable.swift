//
//  File.swift
//  
//
//  Created by ApolloZhu on 2019/8/15.
//

import Foundation

public extension UserDefaultsStorable where Self: RawRepresentable, Self.RawValue: UserDefaultsStorable {
    func asUserDefaultsStorable() -> UserDefaultsStorable! {
        return rawValue.asUserDefaultsStorable()
    }
    static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Self? {
        return RawValue.fromUserDefaults(userDefaults, forKey: key)
            .flatMap(Self.init(rawValue:))
    }
}
