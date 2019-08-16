//
//  EFUnderlyingStorage.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

public protocol EFUnderlyingStorage: Equatable {
    static func makeDefault() -> Self
    
    static func refForKey<T, Ref: EFSingleInstanceStorageReference>(
        _ key: String, in storage: Ref.Storage
    ) -> Ref where T == Ref.Content, Self == Ref.Storage
}

extension EFUnderlyingStorage {
    static func refForKey<T, Ref: EFSingleInstanceStorageReference>(
        _ key: String, in storage: Ref.Storage
    ) -> Ref where T == Ref.Content, Self == Ref.Storage {
        return Ref.forKey(key, in: storage)
    }
}

@dynamicMemberLookup
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

public extension EFUnderlyingStorageWrapper {
    subscript<T, Ref: EFSingleInstanceStorageReference>(
        dynamicMember key: String
    ) -> Ref where T == Ref.Content, Base == Ref.Storage {
        return Ref.Storage.refForKey(key, in: base)
    }
    
    subscript<T, Ref: EFSingleInstanceStorageReference>(
        dynamicMember key: String
    ) -> Ref where T == Ref.Content, Base == Ref.Storage.Type {
        return Ref.Storage.refForKey(key, in: Ref.Storage.makeDefault())
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
public extension EFUnderlyingStorageContentWrapper {
    subscript<T>(
        dynamicMember key: String
    ) -> T? where Base: EFUnderlyingStorage {
        get {
            return baseWrapper.base.efStorage[dynamicMember: key].content
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].content = newValue
        }
    }

    subscript<T>(dynamicMember key: String) -> T? where Base == EFUnderlyingStorage.Type {
        get {
            return baseWrapper.base.efStorage[dynamicMember: key].content
        }
        set {
            baseWrapper.base.efStorage[dynamicMember: key].content = newValue
        }
    }
}
*/
