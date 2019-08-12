@dynamicMemberLookup
public protocol EFStorage {
    associatedtype Content
    
    /// Actual content stored in storage
    var content: Content? { get set }
    /// Non-optional value for property wrappers and dynamic member lookup based on `content`.
    var wrappedValue: Content { get set }
    subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value { mutating get }
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> Value { mutating get set }
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
    fileprivate init(_ a: A, _ b: B) {
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
