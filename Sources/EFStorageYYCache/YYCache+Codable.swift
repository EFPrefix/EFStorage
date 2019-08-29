//
//  File.swift
//  
//
//  Created by ApolloZhu on 2019/8/19.
//

#if canImport(YYCache)
import Foundation
import YYCache

extension YYCacheStorable where Self: Codable {
    func asYYCacheStorable() -> YYCacheStorable! {
        return try? JSONEncoder().encode(self) as NSData
    }
    static func fromYYCache(_ yyCache: YYCache, forKey key: String) -> Self? {
        return NSData.fromYYCache(yyCache, forKey: key).flatMap {
            return try? JSONDecoder().decode(Self.self, from: $0 as Data)
        }
    }
}
#endif
