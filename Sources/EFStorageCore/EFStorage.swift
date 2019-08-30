//
//  EFStorage.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/7.
//

public protocol EFStorage: EFContentWrapper, EFOptionalContentWrapper { }

public class SomeEFStorage<Storage: EFStorage, Content>: EFStorage where Storage.Content == Content {
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

/// Only for migration purposes. Setting the content/wrappedValue does nothing.
public struct EFStorageMigrate<A: EFStorage, OldContent, Content>
: EFStorage where A.Content == OldContent {
    public typealias Migrator = (OldContent) -> Content
    
    public var wrappedValue: Content {
        get { return content ?? migrator(a.wrappedValue) }
        set { }
    }
    
    public var content: Content? {
        get { return a.content.map(migrator) }
        set { }
    }
    
    private var a: A
    private var migrator: Migrator
    public init(from a: A, by migrator: @escaping Migrator) {
        self.a = a
        self.migrator = migrator
    }
}
