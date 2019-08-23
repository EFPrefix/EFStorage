//
//  EFSingleInstanceStorageReference.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

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

internal enum _EFStorages {
    internal typealias Record = [String: NSMapTable<NSString, AnyObject>]
    
    private static var _efStorages = Record()
    private static var lock = NSLock()
    
    /// Modifies _efStorages.
    /// - Parameter mutate: mutating action to perform on _efStorages.
    /// - Warning: calling this method or `read` within each other results in dead lock.
    internal static func modify<T>(by mutate: (inout Record) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try mutate(&_efStorages)
    }
    
    /// Accesses _efStorages.
    /// - Parameter access: non-mutating action to perform on _efStorages.
    /// - Warning: calling this method or `modify` within each other results in dead lock.
    internal static func read<T>(to access: (Record) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try access(_efStorages)
    }
    
    /// Remove all map tables that no longer holds any refrence.
    /// - Parameter efStorages: efStorages to clean up.
    /// - Precondition: with lock obtained.
    fileprivate static func cleanUpIfNeeded(_ efStorages: inout Record) {
        if efStorages.isEmpty { return }
        if efStorages.capacity > efStorages.count { return }
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
        return _EFStorages.modify { record in
            return make(forKey: key, in: storage, record: &record)
        }
    }
    
    /// - Precondition: with _EFStorages lock obtained.
    private static func make(forKey key: String, in storage: Storage,
                             record efStorages: inout _EFStorages.Record) -> Self {
        let typeIdentifier = String(describing: self)
        if efStorages[typeIdentifier] == nil {
            _EFStorages.cleanUpIfNeeded(&efStorages)
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
