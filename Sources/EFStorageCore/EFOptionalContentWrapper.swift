//
//  EFOptionalContentWrapper.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

import Foundation

public protocol EFOptionalContentWrapper {
    associatedtype Content
    
    /// Actual content stored in storage
    var content: Content? { get set }
}

public extension EFOptionalContentWrapper where Content: NSString {
    var string: String? {
        get {
            return content as String?
        }
        set {
            content = newValue as NSString? as? Content
        }
    }
}
