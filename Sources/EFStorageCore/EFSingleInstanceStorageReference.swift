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

var efStorages = [String: NSMapTable<NSString, AnyObject>]()
var efStoragesLock = NSLock()

private func organizeEFStorages() {
    #warning("需要找一个时机调用来清理不需要的容器")
    #warning("Needs performance test once integrated")
    efStoragesLock.lock()
    defer { efStoragesLock.unlock() }
    // http://cocoamine.net/blog/2013/12/13/nsmaptable-and-zeroing-weak-references/
    efStorages = efStorages.filter { $0.value.keyEnumerator().allObjects.count == 0 }
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
        efStoragesLock.lock()
        defer { efStoragesLock.unlock() }
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
