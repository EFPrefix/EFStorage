@dynamicMemberLookup
public protocol EFStorage {
    associatedtype Content
    
    var wrappedValue: Content { mutating get set }
    subscript<Value>(dynamicMember keyPath: KeyPath<Content, Value>) -> Value { mutating get }
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<Content, Value>) -> Value { mutating get set }
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
