//
//  EFOptionalContentWrapper.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import Foundation

/// Protocol for some `EFSingleInstanceStorageReference` and `EFStorage`.
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

public extension EFOptionalContentWrapper where Content: NSString {
    /// Convert to and from NSString
    var string: String? {
        get {
            return content as String?
        }
        set {
            content = newValue as NSString? as? Content
        }
    }
}
