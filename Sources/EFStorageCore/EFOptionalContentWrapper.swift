//
//  EFOptionalContentWrapper.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

public protocol EFOptionalContentWrapper {
    associatedtype Content
    
    /// Actual content stored in storage
    var content: Content? { get set }
}
