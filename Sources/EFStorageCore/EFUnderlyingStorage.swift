//
//  EFUnderlyingStorage.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

public protocol EFUnderlyingStorage: Equatable {
    static func makeDefault() -> Self
    
//    associatedtype Ref: EFSingleInstanceStorageReference where Self == Ref.Storage
//    func refForKey<T>(_ key: String, in storage: Ref.Storage) -> Ref where T == Ref.Content
}

//extension EFUnderlyingStorage {
//    func refForKey<T>(_ key: String, in storage: Ref.Storage) -> Ref where T == Ref.Content {
//        return Ref.forKey(key, in: self)
//    }
//}

public struct EFUnderlyingStorageWrapper<Base> {
    public let base: Base
    fileprivate init(_ base: Base) {
        self.base = base
    }
}

public extension EFUnderlyingStorage {
    var efStorage: EFUnderlyingStorageWrapper<Self> {
        return EFUnderlyingStorageWrapper(self)
    }
    
    static var efStorage: EFUnderlyingStorageWrapper<Self.Type> {
        return EFUnderlyingStorageWrapper(Self.self)
    }
}

public struct EFUnderlyingStorageContentWrapper<Base> {
    public let baseWrapper: EFUnderlyingStorageWrapper<Base>
    fileprivate init(_ baseWrapper: EFUnderlyingStorageWrapper<Base>) {
        self.baseWrapper = baseWrapper
    }
}

public extension EFUnderlyingStorage {
    var efStorageContents: EFUnderlyingStorageContentWrapper<Self> {
        return EFUnderlyingStorageContentWrapper(efStorage)
    }
    
    static var efStorageContents: EFUnderlyingStorageContentWrapper<Self.Type> {
        return EFUnderlyingStorageContentWrapper(efStorage)
    }
}

/*
public extension EFStorageWrapper {
    subscript<T: UserDefaultsStorable, Ref: EFSingleInstanceStorageReference>(
        dynamicMember key: String
    ) -> Ref<T> where Base == EFStorageWrapperBase {
        return Ref<T>.forKey(key, in: base)
    }
    
    subscript<T: UserDefaultsStorable, Ref: EFSingleInstanceStorageReference>(
        dynamicMember key: String
    ) -> Ref<T> where Base == EFStorageWrapperBase.Type {
        return Ref<T>.forKey(key, in: Base.makeDefault())
    }
}

public extension EFStorageContentWrapper {
    subscript<T: UserDefaultsStorable>(dynamicMember key: String) -> T? where Base == EFStorageWrapperBase {
        get {
            return baseWrapper.base.efStorage[dynamicMember: key].content
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].content = newValue
        }
    }
    
    subscript<T: UserDefaultsStorable>(dynamicMember key: String) -> T? where Base == EFStorageWrapperBase.Type {
        get {
            return baseWrapper.base.efStorage[dynamicMember: key].content
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].content = newValue
        }
    }
}
 */
