//
//  File.swift
//  
//
//  Created by ApolloZhu on 2019/8/19.
//

#if canImport(YYCache)
import Foundation
import YYCache

public extension YYCacheStorable where Self: NSCoding {
    func asYYCacheStorable() -> YYCacheStorable! {
        return self
    }
    static func fromYYCache(_ yyCache: YYCache, forKey key: String) -> Self? {
        return yyCache.object(forKey: key) as? Self
    }
}

extension NSData: YYCacheStorable { }
extension NSArray: YYCacheStorable { }
extension NSNumber: YYCacheStorable { }
#endif
