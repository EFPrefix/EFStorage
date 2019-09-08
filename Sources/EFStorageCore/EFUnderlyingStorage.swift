//
//  EFUnderlyingStorage.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

public protocol EFUnderlyingStorage: Equatable {
    static func makeDefault() -> Self
}

public protocol EFFailableUnderlyingStorage: EFUnderlyingStorage {
    static func makeDefault() -> Self?
}

extension EFFailableUnderlyingStorage {
    public dynamic static func makeDefault() -> Self {
        return makeDefault()!
    }
}

extension Optional: EFUnderlyingStorage where Wrapped: EFFailableUnderlyingStorage {
    public dynamic static func makeDefault() -> Self {
        return Wrapped.makeDefault() ?? nil
    }
}

@dynamicMemberLookup
public final class EFUnderlyingStorageWrapper<Base> {
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
        return Ref.forKey(key, in: base)
    }
    
    subscript<T, Ref: EFSingleInstanceStorageReference>(
        dynamicMember key: String
    ) -> Ref where T == Ref.Content, Base == Ref.Storage.Type {
        return Ref.forKey(key, in: Ref.Storage.makeDefault())
    }
}
