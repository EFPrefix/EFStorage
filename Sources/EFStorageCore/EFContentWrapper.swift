//
//  EFContentWrapper.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import Foundation

#if swift(>=5.1)
#error("Please update EFStorage to newest version for @propertyWrapper and more.")
#endif

public protocol EFContentWrapper {
    associatedtype Content
    
    /// Non-optional value for property wrappers and dynamic member lookup.
    var wrappedValue: Content { get set }
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
