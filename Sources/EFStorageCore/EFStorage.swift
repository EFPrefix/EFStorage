//
//  EFStorage.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/7.
//

@dynamicMemberLookup
public protocol EFStorage: EFContentWrapper, EFOptionalContentWrapper { }

/// A wrapper around some kind of `EFStorage`.
///
/// This is especially useful when you don't want to expose the exact type,
/// or as a property wrapper when underlying implementation
/// is composed using `+` from many `EFStorage`s like this:
///
///     @SomeEFStorage(
///         EFStorageKeychainAccess(forKey: "paidBefore", defaultsTo: false)
///         + EFStorageUserDefaults(forKey: "paidBefore", defaultsTo: false)
///         + EFStorageUserDefaults(forKey: "oldHasPaidBeforeKey",
///                                 defaultsTo: true,
///                                 persistDefaultContent: true))
///     var hasPaidBefore: Bool
@propertyWrapper
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
    /// Compose two `EFStorage`s together.
    /// - Parameter lhs: prioritized storage.
    /// - Parameter rhs: secondary storage.
    ///
    /// You can use this to combine multiple `EFStorage`s together, then pass it to `SomeEFStorage`:
    ///
    ///     @SomeEFStorage(
    ///         EFStorageKeychainAccess(forKey: "paidBefore", defaultsTo: false)
    ///         + EFStorageUserDefaults(forKey: "paidBefore", defaultsTo: false)
    ///         + EFStorageUserDefaults(forKey: "oldHasPaidBeforeKey",
    ///                                 defaultsTo: true,
    ///                                 persistDefaultContent: true))
    ///     var hasPaidBefore: Bool
    static func +<AnotherStorage: EFStorage>(lhs: Self, rhs: AnotherStorage)
        -> EFStorageComposition<Self, AnotherStorage, Content> {
            return EFStorageComposition(lhs, rhs)
    }
}

/// Combine two `EFStorage`s into one.
///
///     @EFStorageComposition(
///         EFStorageUserDefaults(forKey: "isNewUser", defaultsTo: false),
///         EFStorageKeychainAccess(forKey: "isNewUser", defaultsTo: false))
///     var isNewUser: Bool
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

/// Read-only storage that migrates content from one data type to another.
///
/// This is very useful when the old storage has a different data type than the new one.
///
///     @EFStorageComposition(
///         EFStorageUserDefaults<String>(forKey: "sameKey",
///                                       defaultsTo: "Nah"),
///         EFStorageMigrate(
///             from: EFStorageUserDefaults<Int>(
///                 forKey: "sameKey",
///                 defaultsTo: 1551,
///                 persistDefaultContent: true),
///             by: { number in String(number) }
///         )
///     )
///     var mixedType: String
///
/// - Important: Only for migration purposes. Setting the content/wrappedValue does nothing.
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
