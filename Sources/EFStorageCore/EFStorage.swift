@dynamicMemberLookup
public protocol EFContentWrapper {
    associatedtype Content
    
    /// Non-optional value for property wrappers and dynamic member lookup based on `content`.
    var wrappedValue: Content { get set }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value { get }
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> Value { get set }
}

public extension EFContentWrapper {
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

@dynamicMemberLookup
public protocol EFOptionalContentWrapper {
    associatedtype Content
    
    /// Actual content stored in storage
    var content: Content? { get set }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value? { get }
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> Value? { get set }
}

public extension EFOptionalContentWrapper {
    subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value? {
        get { return content?[keyPath: keyPath] }
    }
    
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> Value? {
        get { return content?[keyPath: keyPath] }
        set { newValue.map { content?[keyPath: keyPath] = $0 } }
    }
}

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

public protocol EFSingleInstanceStorageReferenceWrapper: EFStorage, CustomDebugStringConvertible {
    associatedtype Ref: EFSingleInstanceStorageReference where Content == Ref.Content
    var key: String { get }
    var _ref: Ref { get set }
    
    var persistDefaultContent: Bool { get }
    var makeDefaultContent: () -> Content { get }
    func removeContentFromUnderlyingStorage()
    
    init(
        iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself ignored: Bool,
        ref: Ref, makeDefaultContent: @escaping () -> Content, persistDefaultContent: Bool
    )
}

public extension EFSingleInstanceStorageReferenceWrapper {
    var key: String {
        return _ref.key
    }
    
    var content: Content? {
        get { return _ref.content }
        set { _ref.content = newValue }
    }
    
    var debugDescription: String {
        let storageName = String(describing: Ref.Storage.self)
        return "\(storageName)[\(key)] : \(content ?? makeDefaultContent())"
    }
    
    init(
        forKey key: String, in storage: Ref.Storage = Ref.Storage.makeDefault(),
        defaultsTo makeDefaultContent: @escaping @autoclosure () -> Content,
        persistDefaultContent: Bool = false
    ) {
        self.init(
            iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: true,
            ref: Ref.forKey(key, in: storage),
            makeDefaultContent: makeDefaultContent,
            persistDefaultContent: persistDefaultContent
        )
        if _ref.content == nil, persistDefaultContent {
            _ref.content = makeDefaultContent()
        }
    }
}

public protocol EFUnderlyingStorage: Equatable {
    static func makeDefault() -> Self
}

@dynamicMemberLookup
public protocol EFSingleInstanceStorageReference: AnyObject, EFOptionalContentWrapper, CustomDebugStringConvertible {
    associatedtype Storage: EFUnderlyingStorage
    
    var key: String { get }
    var storage: Storage { get }
    
    /// A method that should only be invoked by the static constructor `forKey(_:in:)`.
    init(
        iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself ignored: Bool,
        forKey key: String, in storage: Storage
    )
}

import Foundation

var efStorages = [String: NSMapTable<NSString, AnyObject>]()

extension EFSingleInstanceStorageReference {
    public var debugDescription: String {
        let storageName = String(describing: Storage.self)
        return "\(storageName)[\(key)] : \(content.debugDescription)"
    }
    
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
            iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: true,
            forKey: key, in: storage
        )
        efStorages[typeIdentifier]?.setObject(newInstance, forKey: key as NSString)
        debugPrint("CREAT \(typeIdentifier) \(key)")
        return newInstance
    }
}
