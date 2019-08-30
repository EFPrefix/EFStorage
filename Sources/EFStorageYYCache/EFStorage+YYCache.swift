//
//  EFStorage+YYCache.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/19.
//

#if canImport(YYCache)
import Foundation
import YYCache
#if canImport(EFStorageCore)
import EFStorageCore
#endif

extension YYCache: EFFailableUnderlyingStorage {
    fileprivate static let name = Bundle.main.bundleIdentifier ?? "EFStorage"
    fileprivate static var shared = YYCache(name: name)
}

extension EFFailableUnderlyingStorage where Self: YYCache {
    public dynamic static func makeDefault() -> Self? {
        return (shared as? Self) ?? Self(name: name)
    }
}

public protocol YYCacheStorable {
    func asYYCacheStorable() -> YYCacheStorable!
    static func fromYYCache(_ yyCache: YYCache, forKey key: String) -> Self?
}

public class EFStorageYYCacheRef<Content: YYCacheStorable>
: EFSingleInstanceStorageReference {
    public required init(
        iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: Bool,
        forKey key: String, in storage: YYCache?
    ) {
        self.key = key
        self.storage = storage
        self.content = storage.flatMap { Content.fromYYCache($0, forKey: key) }
    }
    
    public let key: String
    public let storage: YYCache?
    public var content: Content? {
        didSet {
            guard let newValue = content else {
                storage?.removeObject(forKey: key)
                return
            }
            guard let storable = newValue.asYYCacheStorable() as? NSCoding else {
                assertionFailure("""
                \(newValue) of type \(type(of: newValue)) \
                is not storable in YYCache.
                """)
                storage?.removeObject(forKey: key)
                return
            }
            storage?.setObject(storable, forKey: key)
        }
    }
    
    deinit {
        _efStorageLog("CLEAR \(String(describing: self)) \(key)")
    }
}

public struct EFStorageYYCache<Content: YYCacheStorable>: EFSingleInstanceStorageReferenceWrapper {
    public var _ref: EFStorageYYCacheRef<Content>
    public var wrappedValue: Content {
        get {
            if let content = _ref.content { return content }
            let defaultContent = makeDefaultContent()
            if persistDefaultContent { _ref.content = defaultContent }
            return defaultContent
        }
        set { _ref.content = newValue }
    }
    
    public let persistDefaultContent: Bool
    public let makeDefaultContent: () -> Content
    public func removeContentFromUnderlyingStorage() {
        _ref.content = nil
    }
    
    public init(
        __ref: EFStorageYYCacheRef<Content>,
        makeDefaultContent: @escaping () -> Content,
        persistDefaultContent: Bool
    ) {
        self._ref = __ref
        self.makeDefaultContent = makeDefaultContent
        self.persistDefaultContent = persistDefaultContent
    }
}

public extension EFUnderlyingStorageWrapper {
    subscript<T: YYCacheStorable>(
        dynamicMember key: String
    ) -> T? where Base == YYCache {
        get {
            return EFStorageYYCacheRef.forKey(key, in: base).content
        }
        set {
            EFStorageYYCacheRef.forKey(key, in: base).content = newValue
        }
    }
    
    subscript<T: YYCacheStorable>(
        dynamicMember key: String
    ) -> T? where Base == YYCache.Type {
        get {
            return EFStorageYYCacheRef.forKey(key, in: YYCache.makeDefault()).content
        }
        set {
            EFStorageYYCacheRef.forKey(key, in: YYCache.makeDefault()).content = newValue
        }
    }
}
#elseif canImport(EFStorageCore)
#warning("EFStorageYYCache is not available")
#else
#warning("EFStorage/YYCache is not available")
#endif
