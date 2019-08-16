//
//  EFStorage.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/7.
//

@dynamicMemberLookup
public protocol EFStorage: EFContentWrapper, EFOptionalContentWrapper { }

@propertyWrapper
public class AnyEFStorage<Storage: EFStorage, Content>: EFStorage where Storage.Content == Content {
    public var content: Content? {
        get { return storage.content }
        set { storage.content = newValue }
    }
    
    public var wrappedValue: Content {
        get { return storage.wrappedValue }
        set { storage.wrappedValue = newValue }
    }
    
    private var storage: Storage
    
    public init(_ storage: Storage)  {
        self.storage = storage
    }
}

public extension EFStorage {
    static func +<AnotherStorage: EFStorage>(lhs: Self, rhs: AnotherStorage)
        -> EFStorageComposition<Self, AnotherStorage, Content> {
            return EFStorageComposition(lhs, rhs)
    }
}

@propertyWrapper
public struct EFStorageComposition<A: EFStorage, B: EFStorage, Content>
: EFStorage where Content == A.Content, Content == B.Content {
    public var wrappedValue: Content {
        get {
            return content ?? a.wrappedValue
        }
        set {
            a.wrappedValue = newValue
            b.wrappedValue = newValue
        }
    }
    
    public var content: Content? {
        get {
            return a.content ?? b.content
        }
        set {
            a.content = newValue
            b.content = newValue
        }
    }
    
    private var a: A
    private var b: B
    public init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
}

// MARK: - Direct Lookup

public protocol EFUnderlyingStorage: Equatable {
    static func makeDefault() -> Self
}

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
