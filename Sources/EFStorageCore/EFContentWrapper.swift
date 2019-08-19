//
//  EFContentWrapper.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import Foundation

@dynamicMemberLookup
public protocol EFContentWrapper {
    associatedtype Content
    
    /// Non-optional value for property wrappers and dynamic member lookup.
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

public extension EFContentWrapper where Content: NSString {
    var string: String {
        get {
            return wrappedValue as String
        }
        set {
            wrappedValue = newValue as NSString as! Content
        }
    }
}
