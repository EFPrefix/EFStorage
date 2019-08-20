//
//  EFSingleInstanceStorageReference.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

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

internal enum _EFStorages {
    internal typealias Table = [String: NSMapTable<NSString, AnyObject>]
    
    private static var _efStorages = Table() {
        didSet {
            if oldValue.capacity != _efStorages.capacity {
                modify(by: organize)
            }
        }
    }
    
    /// `organize` happens when `lock` is obtained, so it has to be recursive
    private static var lock = NSRecursiveLock()

    internal static func modify<T>(by mutate: (inout Table) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try mutate(&_efStorages)
    }
    
    internal static func read<T>(by access: (Table) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try access(_efStorages)
    }
    
    private static func organize(_ efStorages: inout Table) {
        _efStorageLog("CLEAN START \(efStorages.count)")
        // http://cocoamine.net/blog/2013/12/13/nsmaptable-and-zeroing-weak-references/
        efStorages = efStorages.filter { !$0.value.keyEnumerator().allObjects.isEmpty }
        _efStorageLog("CLEAN AFTER \(efStorages.count)")
    }
}

@inlinable
public func _efStorageLog(_ s: String) {
    #if DEBUG
    print(s)
    #endif
}

extension EFSingleInstanceStorageReference {
    public var debugDescription: String {
        let storageName = String(describing: Storage.self)
        return "\(storageName)[\(key)] : \(content.debugDescription)"
    }
    
    public static func forKey(_ key: String, in storage: Storage = Storage.makeDefault()) -> Self {
        return _EFStorages.modify { efStorages in
            return make(forKey: key, in: storage, efStorages: &efStorages)
        }
    }
    
    private static func make(forKey key: String, in storage: Storage,
                             efStorages: inout _EFStorages.Table) -> Self {
        let typeIdentifier = String(describing: self)
        if efStorages[typeIdentifier] == nil {
            _efStorageLog("ALLOC \(typeIdentifier)")
            efStorages[typeIdentifier] = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
        }
        if let object = efStorages[typeIdentifier]?.object(forKey: key as NSString),
            let instanceOfSelfType = object as? Self, storage == storage {
            _efStorageLog("FETCH \(typeIdentifier) \(key)")
            return instanceOfSelfType
        }
        let newInstance = Self(
            iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: true,
            forKey: key, in: storage
        )
        efStorages[typeIdentifier]?.setObject(newInstance, forKey: key as NSString)
        _efStorageLog("CREAT \(typeIdentifier) \(key)")
        return newInstance
    }
}
