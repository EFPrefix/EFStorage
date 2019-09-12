//
//  EFSingleInstanceStorageReference.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import Foundation

/// Supposedly singleton protocol if you only make instances using the `forKey(_:in:)` statis method.
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

extension EFSingleInstanceStorageReference {
    public var debugDescription: String {
        let storageName = String(describing: Storage.self)
        return "\(storageName)[\(key)] : \(content.debugDescription)"
    }
    
    /// Make reference into `storage`, identified by `key`.
    /// - Parameter key: identifier for the stored content.
    /// - Parameter storage: where content should be stored to.
    public static func forKey(_ key: String, in storage: Storage = Storage.makeDefault()) -> Self {
        return _EFStorageInternal.modify { record in
            return make(forKey: key, in: storage, record: &record)
        }
    }
    
    /// - Precondition: with _EFStorages lock obtained.
    private static func make(forKey key: String, in storage: Storage,
                             record efStorages: inout _EFStorageInternal.Record) -> Self {
        let typeIdentifier = String(describing: self)
        if efStorages[typeIdentifier] == nil {
            _EFStorageInternal._cleanUpIfNeeded(&efStorages)
            _efStorageLog("ALLOC \(typeIdentifier)")
            efStorages[typeIdentifier] = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
        }
        if let object = efStorages[typeIdentifier]?.object(forKey: key as NSString),
            let instanceOfSelfType = object as? Self, storage == storage {
            _efStorageLog("FETCH \(typeIdentifier) \(key) FROM \(storage)")
            return instanceOfSelfType
        }
        let newInstance = Self(
            iKnowIShouldNotCallThisDirectlyAndIsResponsibleForUnexpectedBehaviorMyself: true,
            forKey: key, in: storage
        )
        efStorages[typeIdentifier]?.setObject(newInstance, forKey: key as NSString)
        _efStorageLog("CREAT \(typeIdentifier) \(key) IN \(storage)")
        return newInstance
    }
}
