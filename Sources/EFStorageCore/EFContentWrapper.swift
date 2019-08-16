//
//  File.swift
//  
//
//  Created by ApolloZhu on 2019/8/16.
//

import Foundation

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

public extension EFContentWrapper where Content: NSString {
    var string: String {
        mutating get {
            return wrappedValue as String
        }
        set {
            wrappedValue = newValue as NSString as! Content
        }
    }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<String, Value>) -> Value {
        mutating get { return string[keyPath: keyPath] }
    }
    
    subscript<Value>(dynamicMember keyPath: WritableKeyPath<String, Value>) -> Value {
        mutating get { return string[keyPath: keyPath] }
        set { string[keyPath: keyPath] = newValue }
    }
}
