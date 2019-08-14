@dynamicMemberLookup
public protocol EFContentWrapper {
    associatedtype Content
    
    subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value { get }
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> Value { get set }
}

@dynamicMemberLookup
public protocol EFStorage: EFContentWrapper {
    /// Actual content stored in storage
    var content: Content? { get set }
    /// Non-optional value for property wrappers and dynamic member lookup based on `content`.
    var wrappedValue: Content { get set }
}

public extension EFStorage {
    subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value {
        return wrappedValue[keyPath: keyPath]
    }

    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> Value {
        get {
            return wrappedValue[keyPath: keyPath]
        }
        set {
            wrappedValue[keyPath: keyPath] = newValue
        }
    }
}

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

@dynamicMemberLookup
public struct EFStorageWrapper<Base> {
    public let base: Base
    fileprivate init(_ base: Base) {
        self.base = base
    }
}

public protocol EFStorageWrapperBase { }

public extension EFStorageWrapperBase {
    var efStorage: EFStorageWrapper<Self> {
        return EFStorageWrapper(self)
    }
    
    static var efStorage: EFStorageWrapper<Self.Type> {
        return EFStorageWrapper(Self.self)
    }
}

// MARK: - Direct Value Lookup

@dynamicMemberLookup
public struct EFStorageContentWrapper<Base> {
    public let baseWrapper: EFStorageWrapper<Base>
    fileprivate init(_ baseWrapper: EFStorageWrapper<Base>) {
        self.baseWrapper = baseWrapper
    }
}

public extension EFStorageWrapperBase {
    var efStorageContents: EFStorageContentWrapper<Self> {
        return EFStorageContentWrapper(efStorage)
    }
    
    static var efStorageContents: EFStorageContentWrapper<Self.Type> {
        return EFStorageContentWrapper(efStorage)
    }
}

// MARK: - Single Instance Container

@dynamicMemberLookup
public protocol EFOptionalContentWrapper {
    associatedtype Content
    
    subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value? { get }
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> Value? { get set }
}

@dynamicMemberLookup
public protocol EFSingleInstanceStorageReference: AnyObject, EFOptionalContentWrapper {
    associatedtype Storage: Equatable
    associatedtype Content
    
    var value: Content? { get set }
    
    /// A method that should only be invoked by the static constructor `forKey(_:in:)`.
    init(forKey key: String, in storage: Storage,
         iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: Bool)
}

public extension EFSingleInstanceStorageReference {
    subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value? {
        get { return value?[keyPath: keyPath] }
    }
    
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> Value? {
        get { return value?[keyPath: keyPath] }
        set { newValue.map { value?[keyPath: keyPath] = $0 } }
    }
}

import Foundation

var efStorages = [String: NSMapTable<NSString, AnyObject>]()

extension EFSingleInstanceStorageReference {
    public static func forKey(_ key: String, in storage: Storage) -> Self {
        let typeIdentifier = String(describing: self)
        if efStorages[typeIdentifier] == nil {
            debugPrint("ALLOC \(typeIdentifier)")
            efStorages[typeIdentifier] = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
        }
        if let object = efStorages[typeIdentifier]?.object(forKey: key as NSString),
            let instanceOfSelfType = object as? Self, storage == storage {
            debugPrint("FETCH \(typeIdentifier) \(key)")
            return instanceOfSelfType
        }
        let newInstance = Self(
            forKey: key, in: storage,
            iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: true
        )
        efStorages[typeIdentifier]?.setObject(newInstance, forKey: key as NSString)
        debugPrint("CREAT \(typeIdentifier) \(key)")
        return newInstance
    }
}
