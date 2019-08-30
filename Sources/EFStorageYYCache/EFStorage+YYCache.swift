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
    private static let name = Bundle.main.bundleIdentifier ?? "EFStorage"
    private static let shared: YYCache? = YYCache(name: name)
    public dynamic class func makeDefault() -> Self? {
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
            if let newValue = content {
                storage?.setObject(newValue.asYYCacheStorable() as? NSCoding, forKey: key)
            } else {
                storage?.removeObject(forKey: key)
            }
        }
    }
    
    deinit {
        _efStorageLog("CLEAR \(String(describing: self)) \(key)")
    }
}

@propertyWrapper
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
            return EFStorageYYCacheRef.forKey(key).content
        }
        set {
            EFStorageYYCacheRef.forKey(key).content = newValue
        }
    }
}
#elseif canImport(EFStorageCore)
#warning("EFStorageYYCache is not available")
#else
#warning("EFStorage/YYCache is not available")
#endif
