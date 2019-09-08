//
//  _EFStorageInternal.swift
//  EFStorage
//
//  Created by Apollo Zhu on 9/7/19.
//

import Foundation

@inlinable
public func _efStorageLog(_ s: String) {
    #if DEBUG
    print("EFStorage", terminator: " ")
    print(s)
    #endif
}

public enum _EFStorageInternal {
    internal typealias Record = [String: NSMapTable<NSString, AnyObject>]
    
    private static var _efStorages = Record()
    private static let lock = NSLock()
    
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
    
    /// Minimum number of entries for different types of singleton refrences
    /// in cache before cleanup happens. Default is (arbitrarily chosen as) 10.
    public static var threshold: UInt = 10
    
    /// Remove all map tables that no longer holds any refrence.
    /// - Parameter efStorages: efStorages to clean up.
    /// - Precondition: with lock obtained.
    internal static func _cleanUpIfNeeded(_ efStorages: inout Record) {
        if efStorages.capacity > efStorages.count { return }
        if threshold > efStorages.count { return }
        _efStorageLog("CLEAN START \(efStorages.count)")
        // http://cocoamine.net/blog/2013/12/13/nsmaptable-and-zeroing-weak-references/
        efStorages = efStorages.filter { !$0.value.keyEnumerator().allObjects.isEmpty }
        _efStorageLog("CLEAN AFTER \(efStorages.count)")
    }
}
